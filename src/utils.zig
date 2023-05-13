const std = @import("std");

const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});

const Renderer = @import("./Renderer/Renderer.zig").Renderer;
const Tileset = @import("./View/Tileset.zig").Tileset;
const Window = @import("./Window/Window.zig").Window;
const Game = @import("./Game/Game.zig").Game;
const EventFile = @import("./Input/Event.zig");
const Event = EventFile.Event;
const EventData = EventFile.EventData;
const EventType = EventFile.EventType;

// An initial test to see if I could generate static
pub fn generateStatic(renderer: Renderer, tileset: Tileset) !void {
    const tileSize: u32 = 20;
    var w: c_int = 0;
    var h: c_int = 0;
    _ = sdl.SDL_GetRendererOutputSize(renderer.renderer, &w, &h);
    const totalTiles = @divFloor(w, tileSize) * @divFloor(h, tileSize);
    var quit = false;
    _ = quit;
    var randomGen = std.rand.DefaultPrng.init(1);
    //while (quit == false) {
    for (0..@intCast(u32, totalTiles)) |i| {
        const val = randomGen.random().intRangeAtMost(u8, 0, 255);
        const tile = try tileset.getTile(val);
        var pos = sdl.SDL_Rect{ .x = @intCast(c_int, @rem(i * tileSize, @intCast(u32, w))), .y = @intCast(c_int, @divFloor(i, @intCast(u32, w) / tileSize) * tileSize), .w = tileSize, .h = tileSize };
        try Window.prepareTexture(renderer.renderer, tile, &pos);
    }
    Window.renderTexture(renderer.renderer);
    //}
}

pub fn flattenArray(allocator: std.mem.Allocator, array: [][]u8) ![]u8 {
    std.debug.print("{}, {}", .{ array.len, array[0].len });
    var newArray: []u8 = try allocator.alloc(u8, @as(u64, array.len * array[0].len));
    var index: u32 = 0;
    for (array) |row| {
        for (row) |element| {
            newArray[index] = element;
            index += 1;
        }
    }
    return newArray;
}

const prng = std.rand.DefaultPrng;
pub fn getNormal() f32 {
    var gen = prng.init(@intCast(u64, std.time.timestamp()));
    const u = gen.random().float(f32);
    const v = gen.random().float(f32);
    const normal = std.math.sqrt(-2.0 * std.math.log(f32, std.math.e, u)) * std.math.cos(2.0 * std.math.pi * v);
    return normal;
}

pub fn abs(a: i16) u8 {
    return if (a < 0) @intCast(u8, -a) else @intCast(u8, a);
}
