const std = @import("std");

pub fn processMap(allocator: std.mem.Allocator, map: [][]u8) ![][]u8 {
    var newMap: [][]u8 = try allocator.alloc([]u8, map.len);
    for (newMap) |*row| {
        row.* = try allocator.alloc(u8, map[0].len);
    }
    for (0..map.len) |y| {
        for (0..map[0].len) |x| {
            const neighbors = processNeighbors(map, @truncate(u8, x), @truncate(u8, y));
            var wallCount: u8 = 0;
            for (neighbors) |neighbor| {
                std.debug.print("{}", .{neighbor});
                if (neighbor == 219) wallCount += 1;
            }
            std.debug.print("done\n", .{});
            if (wallCount > 4) {
                newMap[y][x] = 219;
            } else {
                newMap[y][x] = 250;
            }
        }
    }
    for (map) |row| {
        allocator.free(row);
    }
    allocator.free(map);
    return newMap;
}

fn processNeighbors(map: [][]u8, x: u8, y: u8) []u8 {
    var list: [8]u8 = undefined;
    var counter: u8 = 0;
    for (0..3) |i| {
        for (0..3) |j| {
            if (i == 1 and j == 1) {
                // If it's the current cell, ignore it
            } else if (x + @intCast(i16, i) - 1 >= 0 and x + @intCast(i16, i) - 1 < map[i].len and y + @intCast(i16, j) - 1 >= 0 and y + @intCast(i16, j) - 1 < map.len) {
                // If the neighbor exists
                list[counter] = map[y + j - 1][x + i - 1];
                counter += 1;
            } else {
                // if it doesn't exist, add a wall to the neighbor list
                list[counter] = 219;
                counter += 1;
            }
        }
    }
    //if (counter > 5) {
    std.debug.print("{} friends\n", .{counter});
    //}
    return &list;
}
