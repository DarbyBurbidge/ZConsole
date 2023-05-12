const std = @import("std");
// const getNormal = @import("../utils.zig").getNormal;
const prng = std.rand.DefaultPrng;

const Rect = struct {
    x: u8,
    y: u8,
    w: u8,
    h: u8,
};

const Node = struct {
    x: u8,
    y: u8,
    w: u8,
    h: u8,
    minSize: u8,
    parity: bool, // Parity checks if it was split NS or EW
    depth: u8,
    left: ?*Node,
    right: ?*Node,
    room: ?*Rect,

    fn init(parity: bool, x: u8, y: u8, w: u8, h: u8, minSize: u8) Node {
        std.debug.print("x: {}, y: {}, w: {}, h: {}\n", .{ x, y, w, h });
        return Node{ .x = x, .y = y, .w = w, .h = h, .minSize = minSize, .parity = parity, .depth = 0, .left = null, .right = null, .room = null };
    }

    fn split(self: *@This(), allocator: std.mem.Allocator) !void {
        if (self.w <= self.minSize or self.h <= self.minSize) {
            return error.MapTooSmallForTree;
        }
        if (self.left) |left| if (self.right) |right| {
            // If already split, increase depth by 1 and tell a child to split
            // Default to increasing right depth first
            if (left.depth > right.depth) {
                // std.debug.print("Going right!\n", .{});
                try right.split(allocator);
            } else {
                self.depth += 1;
                // std.debug.print("Going left! NewDepth: {}\n", .{self.depth});
                // std.debug.print("left {any}\n", .{self.left});
                try left.split(allocator);
            }
            return;
        };

        self.left = try allocator.create(Node);
        self.right = try allocator.create(Node);
        var splitPoint: u8 = 0;
        if (self.parity) {
            while (splitPoint < self.minSize or splitPoint > self.w * 2 - self.minSize) {
                splitPoint = @floatToInt(u8, getNormal() * @intToFloat(f32, self.minSize * 2) + @intToFloat(f32, self.x));
            }
            std.debug.print("Splitting Horizontally: {}\n", .{self.depth});
            self.splitHorizontally(splitPoint);
        } else {
            while (splitPoint < self.minSize or splitPoint > self.h * 2 - self.minSize) {
                splitPoint = @floatToInt(u8, getNormal() * @intToFloat(f32, self.minSize * 2) + @intToFloat(f32, self.y));
            }
            std.debug.print("Splitting Vertically: {}\n", .{self.depth});
            self.splitVertically(splitPoint);
        }

        // std.debug.print("Left child: {}\n", .{&self.left});
        // std.debug.print("Right child: {}\n", .{&self.right});
        self.depth += 1;
        // std.debug.print("NewDepth: {}\n", .{self.depth});
    }

    fn splitHorizontally(self: *@This(), splitPoint: u8) void {
        var newWidthL = @divTrunc(splitPoint, 2);
        var newWidthR = @divTrunc(self.w * 2 - splitPoint, 2);
        var newXL = newWidthL;
        var newXR = newWidthR + (newWidthL * 2);
        self.left.?.* = Node.init(!self.parity, newXL, self.y, newWidthL, self.h, self.minSize);

        self.right.?.* = Node.init(!self.parity, newXR, self.y, newWidthR, self.h, self.minSize);
    }

    fn splitVertically(self: *@This(), splitPoint: u8) void {
        var newHeightL = @divTrunc(splitPoint, 2);
        var newHeightR = @divTrunc(self.h * 2 - splitPoint, 2);
        var newYL = newHeightL;
        var newYR = newHeightR + (newHeightL * 2);
        self.left.?.* = Node.init(!self.parity, self.x, newYL, self.w, newHeightL, self.minSize);

        self.right.?.* = Node.init(!self.parity, self.x, newYR, self.w, newHeightR, self.minSize);
    }

    fn generateRooms(self: *@This(), allocator: std.mem.Allocator) !void {
        if (self.left) |left| if (self.right) |right| {
            try left.generateRooms(allocator);
            try right.generateRooms(allocator);
            return;
        };
        try self.createRoom(allocator);
    }

    fn createRoom(self: *@This(), allocator: std.mem.Allocator) !void {
        if (self.w <= self.minSize or self.h <= self.minSize) {
            return error.NodeTooSmallForRoom;
        }
        var gen = prng.init(@intCast(u64, std.time.timestamp()));
        self.room = try allocator.create(Rect);
        self.room.?.* = Rect{
            .x = gen.random().intRangeAtMost(u8, self.x - @divFloor(self.w, 2), self.x + self.w),
            .y = gen.random().intRangeAtMost(u8, self.y - @divFloor(self.h, 2), self.y + self.h),
            .w = gen.random().intRangeAtMost(u8, @divFloor(self.minSize, 2), self.w),
            .h = gen.random().intRangeAtMost(u8, @divFloor(self.minSize, 2), self.h),
        };
    }

    fn getRooms(self: *@This(), allocator: std.mem.Allocator) ![]*Rect {
        if (self.left) |left| if (self.right) |right| {
            var leftRooms = try left.getRooms(allocator);
            var rightRooms = try right.getRooms(allocator);
            var roomList: []*Rect = try allocator.alloc(*Rect, leftRooms.len + rightRooms.len);
            for (leftRooms, 0..) |room, i| {
                roomList[i] = room;
            }
            const leftSize = leftRooms.len;
            for (rightRooms, 0..) |room, i| {
                roomList[leftSize + i] = room;
            }
            // std.debug.print("Rooms: {any}\n", .{roomList});
            return roomList;
        };
        if (self.room) |room| {
            var arrayOfRoomPtr = try allocator.alloc(*Rect, 1);
            arrayOfRoomPtr[0] = room;
            return arrayOfRoomPtr;
        }
        return error.RoomNotInitialized;
    }
};

pub const BSPtree = struct {
    allocator: std.mem.Allocator,
    root: *Node,

    pub fn init(allocator: std.mem.Allocator, map: [][]u8, minSize: u8) !BSPtree {
        var newNode = try allocator.create(Node);
        newNode.* = Node.init(true, @truncate(u8, @divFloor(map[0].len, 2)), @truncate(u8, @divFloor(map.len, 2)), @truncate(u8, @divFloor(map[0].len, 2)), @truncate(u8, @divFloor(map.len, 2)), minSize);
        return BSPtree{
            .allocator = allocator,
            .root = newNode,
        };
    }

    pub fn grow(self: *@This(), sectors: u8) !bool {
        for (0..sectors) |_| {
            std.debug.print("Growing!\n", .{});
            try self.root.split(self.allocator);
        }
        return true;
    }

    pub fn generateRooms(self: *@This()) !void {
        try self.root.generateRooms(self.allocator);
    }

    pub fn getRooms(self: *@This()) ![]*Rect {
        return self.root.getRooms(self.allocator);
    }
};

pub fn getNormal() f32 {
    var gen = prng.init(@intCast(u64, std.time.timestamp()));
    const u = gen.random().float(f32);
    const v = gen.random().float(f32);
    const normal = std.math.sqrt(-2.0 * std.math.log(f32, std.math.e, u)) * std.math.cos(2.0 * std.math.pi * v);
    return normal;
}

test "create rooms" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var map = try allocator.alloc([]u8, 96);
    for (0..map.len) |i| {
        map[i] = try allocator.alloc(u8, 54);
    }
    for (0..map.len) |i| {
        for (0..map[0].len) |j| {
            map[i][j] = 0;
        }
    }
    const minRoomSize = 2;
    var tree = try BSPtree.init(allocator, map, minRoomSize);
    std.debug.print("Tree Succeeded: {!}\n", .{tree.grow(4)});
    try tree.generateRooms();
    const rooms = try tree.getRooms();
    std.debug.print("Rooms: {any}\n", .{rooms});
    for (rooms, 0..) |room, i| {
        _ = room;
        std.debug.print("i: {}, Address: {},  Room: {}\n", .{ i, &rooms[i], rooms[i] });
    }
}
