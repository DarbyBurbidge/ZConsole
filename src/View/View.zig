// ZConsole falls under the ZLIB License
// The license can be found in the root directory
// Copyright (c) 2023 DarbyBurbidge

const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});
const Renderer = @import("../Renderer/Renderer.zig").Renderer;
const Tileset = @import("./Tileset.zig").Tileset;
const Texture = @import("../Renderer/Texture.zig").Texture;
const Rect = @import("../Shapes/Rect.zig");
const Allocator = std.mem.Allocator;

const ViewPortError = error{ InvalidSize, InvalidTileArray };

const ViewType = enum { Console, GameScreen, Menu };
// View is meant to be any in game window that is independent of other windows
// i.e. A menu, The viewport into the game world, the message console.
// They are combined and rendered to a Window, which is what is sent to screen

pub const View = struct {
    size: Rect, // in px
    texture: Texture,

    // Defines the position and size of the View
    pub fn init(renderer: *Renderer, x: u16, y: u16, width: u16, height: u16, tileSize: u8) !View {
        if (@mod(width, tileSize) != 0 or @mod(height, tileSize) != 0) {
            return ViewPortError.InvalidSize;
        }
        const size = Rect{
            .x = x,
            .y = y,
            .w = width,
            .h = height,
        };
        const texture = try Texture.init(renderer, size, .{ .texture = null });
        return View{ .size = size, .texture = texture };
    }

    //Takes an array of characters and a tileset and populates the View with the associated tiles
    pub fn setView(self: @This(), renderer: *Renderer, tileset: *Tileset, tiles: []u8) !void {
        for (tiles, 0..) |tileVal, i| {
            var tile = try tileset.getTile(tileVal);
            var size = Rect{ .x = @truncate(u16, @mod(i * tileset.tileSize, self.size.w)), .y = @truncate(u16, @divFloor(i * tileset.tileSize, self.size.w) * tileset.tileSize), .w = tileset.tileSize, .h = tileset.tileSize };
            //std.debug.print("{}\n", .{tileVal});
            // std.debug.print("x:{}, y:{}, w:{}, h:{}\n", .{ size.x, size.y, size.w, size.h });
            try renderer.blit(self.texture, tileset.texture, .{ .fromSize = &tile, .toSize = &size });
        }
    }

    // Takes an array of tile values and creates a border
    // NOTE: likely to be removed as it is very limited in utility
    // pub fn setBorders(self: *@This(), renderer: *sdl.SDL_Renderer, tileset: *const Tileset, tiles: []u8) !void {
    //     //std.debug.print("Count: {}", .{tileset.*.tiles.count()});
    //     const topTile = try tileset.getTile(tiles[0]);
    //     const rightTile = try tileset.getTile(tiles[2]);
    //     const botTile = try tileset.getTile(tiles[4]);
    //     const leftTile = try tileset.getTile(tiles[6]);
    //     //std.debug.print("Count: {}", .{tileset.tiles.count()});
    //     _ = sdl.SDL_SetRenderTarget(renderer, self.view);
    //     // walk the top row
    //     for (0..@divFloor(@intCast(usize, self.size.w), tileset.tileSize)) |i| {
    //         var size = sdl.SDL_Rect{ .x = @intCast(c_int, i * tileset.tileSize), .y = 0, .w = tileset.tileSize, .h = tileset.tileSize };
    //         _ = sdl.SDL_RenderCopy(renderer, topTile, null, &size);
    //     }
    //     // walk the right side
    //     for (1..@divFloor(@intCast(usize, self.size.h), tileset.tileSize)) |i| {
    //         var size = sdl.SDL_Rect{ .x = self.size.w - tileset.tileSize, .y = @intCast(c_int, i * tileset.tileSize), .w = tileset.tileSize, .h = tileset.tileSize };
    //         _ = sdl.SDL_RenderCopy(renderer, rightTile, null, &size);
    //     }
    //     // walk the bottom
    //     for (1..@divFloor(@intCast(usize, self.size.w), tileset.tileSize)) |i| {
    //         var size = sdl.SDL_Rect{ .x = @intCast(c_int, i * tileset.tileSize), .y = self.size.h - tileset.tileSize, .w = tileset.tileSize, .h = tileset.tileSize };
    //         _ = sdl.SDL_RenderCopy(renderer, botTile, null, &size);
    //     }
    //     //std.debug.print("Count good: {}", .{tileset.tiles.count()});
    //     // walk the left side
    //     for (1..@divFloor(@intCast(usize, self.size.h), tileset.tileSize)) |i| {
    //         var size = sdl.SDL_Rect{ .x = 0, .y = @intCast(c_int, i * tileset.tileSize), .w = tileset.tileSize, .h = tileset.tileSize };
    //         _ = sdl.SDL_RenderCopy(renderer, leftTile, null, &size);
    //     }
    //     //std.debug.print("Count bad: {}", .{tileset.tiles.count()});
    //     // The four corners
    //     for (0..4) |i| {
    //         var size = sdl.SDL_Rect{ .x = @intCast(c_int, i % 2) * (self.size.w - tileset.tileSize), .y = @intCast(c_int, @divFloor(i, 2)) * (self.size.h - tileset.tileSize), .w = tileset.tileSize, .h = tileset.tileSize };
    //         //std.debug.print("x:{}, y:{}, w:{}, h:{}\n", .{ size.x, size.y, size.w, size.h });
    //         //std.debug.print("Count: {}", .{tileset.tiles.count()});
    //         _ = sdl.SDL_RenderCopy(renderer, try tileset.getTile(tiles[(i * 2) + 1]), null, &size);
    //     }

    //     _ = sdl.SDL_SetRenderTarget(renderer, null);
    // }
};
