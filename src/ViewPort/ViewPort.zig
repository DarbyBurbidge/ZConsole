const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});
const Tileset = @import("./Tileset.zig").Tileset;
const Allocator = std.mem.Allocator;

const ViewPortError = error{ InvalidSize, InvalidTileArray };

const ViewType = enum { Console, GameScreen, Menu };

pub const ViewPort = struct {
    size: *sdl.SDL_Rect, // in px
    view: *sdl.SDL_Texture,

    pub fn init(allocator: std.mem.Allocator, renderer: *sdl.SDL_Renderer, width: c_int, height: c_int, tileSize: u8) !ViewPort {
        if (@mod(width, tileSize) != 0 or @mod(height, tileSize) != 0) {
            return ViewPortError.InvalidSize;
        }
        const size = try allocator.create(sdl.SDL_Rect);
        size.x = 0;
        size.y = 0;
        size.w = width;
        size.h = height;
        const texture = sdl.SDL_CreateTexture(renderer, sdl.SDL_PIXELFORMAT_RGBA8888, sdl.SDL_TEXTUREACCESS_TARGET, width, height) orelse return error.TextureLoad;
        return ViewPort{ .size = size, .view = texture };
    }

    pub fn dinit(self: @This(), allocator: *std.mem.Allocator) !void {
        allocator.free(self.tiles);
    }

    pub fn setView(self: @This(), renderer: *sdl.SDL_Renderer, tileset: Tileset, tiles: []u8) !void {
        _ = sdl.SDL_SetRenderTarget(renderer, self.view);
        for (tiles, 0..) |tileVal, i| {
            const tile = try tileset.getTile(tileVal);
            var size = sdl.SDL_Rect{ .x = @mod(@intCast(c_int, i) * 20, self.size.w), .y = @divFloor(@truncate(u16, i) * 20, self.size.w), .w = tileset.tileSize, .h = tileset.tileSize };

            std.debug.print("x:{}, y:{}, w:{}, h:{}\n", .{ size.x, size.y, size.w, size.h });
            _ = sdl.SDL_RenderCopy(renderer, tile, null, &size);
        }
        _ = sdl.SDL_SetRenderTarget(renderer, null);
    }

    pub fn setBorders(self: @This(), renderer: *sdl.SDL_Renderer, tileset: Tileset, tiles: []u8) !void {
        const topTile = try tileset.getTile(tiles[0]);
        const rightTile = try tileset.getTile(tiles[2]);
        const botTile = try tileset.getTile(tiles[4]);
        const leftTile = try tileset.getTile(tiles[6]);
        _ = sdl.SDL_SetRenderTarget(renderer, self.view);
        // walk the top row
        for (0..@divFloor(@intCast(usize, self.size.w), tileset.tileSize)) |i| {
            var size = sdl.SDL_Rect{ .x = @intCast(c_int, i * tileset.tileSize), .y = 0, .w = tileset.tileSize, .h = tileset.tileSize };
            _ = sdl.SDL_RenderCopy(renderer, topTile, null, &size);
        }
        // walk the right side
        for (1..@divFloor(@intCast(usize, self.size.h), tileset.tileSize)) |i| {
            var size = sdl.SDL_Rect{ .x = self.size.w - tileset.tileSize, .y = @intCast(c_int, i * tileset.tileSize), .w = tileset.tileSize, .h = tileset.tileSize };
            _ = sdl.SDL_RenderCopy(renderer, rightTile, null, &size);
        }
        // walk the bottom
        for (1..@divFloor(@intCast(usize, self.size.w), tileset.tileSize)) |i| {
            var size = sdl.SDL_Rect{ .x = @intCast(c_int, i * tileset.tileSize), .y = self.size.h - tileset.tileSize, .w = tileset.tileSize, .h = tileset.tileSize };
            _ = sdl.SDL_RenderCopy(renderer, botTile, null, &size);
        }
        // walk the left side
        for (1..@divFloor(@intCast(usize, self.size.h), tileset.tileSize)) |i| {
            var size = sdl.SDL_Rect{ .x = 0, .y = @intCast(c_int, i * tileset.tileSize), .w = tileset.tileSize, .h = tileset.tileSize };
            _ = sdl.SDL_RenderCopy(renderer, leftTile, null, &size);
        }
        // The four corners
        for (0..4) |i| {
            var size = sdl.SDL_Rect{ .x = @intCast(c_int, i % 2) * (self.size.w - tileset.tileSize), .y = @intCast(c_int, @divFloor(i, 2)) * (self.size.h - tileset.tileSize), .w = tileset.tileSize, .h = tileset.tileSize };
            std.debug.print("x:{}, y:{}, w:{}, h:{}\n", .{ size.x, size.y, size.w, size.h });
            _ = sdl.SDL_RenderCopy(renderer, try tileset.getTile(tiles[i * 2 + 1]), null, &size);
        }

        _ = sdl.SDL_SetRenderTarget(renderer, null);
    }
};
