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
