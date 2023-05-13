// ZConsole falls under the ZLIB License
// The license can be found in the root directory
// Copyright (c) 2023 DarbyBurbidge

const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});

const Renderer = @import("../Renderer/Renderer.zig").Renderer;
const Texture = @import("../Renderer/Texture.zig").Texture;
const Rect = @import("../Shapes/Rect.zig");

const print = std.debug.print;

const TilesetError = error{ TextureLoad, TileLoad, TileTransfer };

pub const Tileset = struct {
    tileset: Texture,
    tiles: std.AutoHashMap(u8, Rect),
    tileSize: u8,
    width: u32,
    height: u32,

    pub fn getTile(self: @This(), tile: u8) !Rect {
        // print("Get Tile: {}, Count: {}\n", .{ tile, self.tiles.count() });
        return self.tiles.get(tile) orelse undefined;
    }

    fn loadImage(renderer: *Renderer, path: []const u8) !Texture {
        if (sdl.IMG_Init(sdl.IMG_INIT_PNG) == 0) {
            // print("Failed to initialize SDL_Image: {*}\n", .{sdl.IMG_GetError()});
            return error.SDLInitializationFailed;
        }
        defer sdl.IMG_Quit();

        const sdlTexture = sdl.IMG_LoadTexture(renderer.renderer, @ptrCast([*c]const u8, path)) orelse {
            // print("{*}", .{sdl.IMG_GetError()});
            return error.TextureLoad;
        };
        var textureSize = sdl.SDL_Rect{
            .x = 0,
            .y = 0,
            .w = 0,
            .h = 0,
        };
        _ = sdl.SDL_QueryTexture(sdlTexture, null, null, &textureSize.w, &textureSize.h);
        var newTileset = try Texture.init(renderer, Rect.fromSDL(textureSize), .{ .texture = sdlTexture });
        return newTileset;
    }

    fn setTiles(renderer: *Renderer, tileset: Texture, tileSize: u8, tileMap: *std.AutoHashMap(u8, Rect)) !void {
        _ = renderer;
        const rows: u16 = @truncate(u16, @intCast(u32, @divFloor(tileset.size.h, tileSize)));
        const cols: u16 = @truncate(u16, @intCast(u32, @divFloor(tileset.size.w, tileSize)));
        var idx: u16 = 0;
        for (0..rows) |row| {
            for (0..cols) |col| {
                const tileRect = Rect{
                    .x = @truncate(u16, col) * tileSize,
                    .y = @truncate(u16, row) * tileSize,
                    .w = tileSize,
                    .h = tileSize,
                };
                try tileMap.put(@truncate(u8, idx), tileRect);
                idx += 1;
            }
        }
        // print("{}", .{tileMap.count()});
    }

    fn createTileTexture(renderer: *sdl.SDL_Renderer, src: *sdl.SDL_Texture, tileRect: *const sdl.SDL_Rect) !*sdl.SDL_Texture {
        const newTile = sdl.SDL_CreateTexture(renderer, sdl.SDL_PIXELFORMAT_RGBA8888, sdl.SDL_TEXTUREACCESS_TARGET, tileRect.w, tileRect.h) orelse return error.CreationFailed;
        if (sdl.SDL_SetRenderTarget(renderer, newTile) != 0) {
            return error.RenderTarget;
        }

        _ = sdl.SDL_RenderCopy(renderer, src, tileRect, null);
        if (sdl.SDL_SetRenderTarget(renderer, null) != 0) {
            return error.RenderTarget;
        }

        return newTile;
    }

    pub fn init(allocator: std.mem.Allocator, renderer: *Renderer, path: []const u8, tileSize: u8) !Tileset {
        if (renderer == undefined) {
            return error.MissingRenderer;
        }
        var tiles = std.AutoHashMap(u8, Rect).init(allocator);
        const tileset = try loadImage(renderer, path);
        try setTiles(renderer, tileset, tileSize, &tiles);
        // print("Init scope Count: {}", .{tiles.count()});
        var tilesetSize = sdl.SDL_Rect{ .x = 0, .y = 0, .w = 0, .h = 0 };

        return Tileset{ .tileset = tileset, .tiles = tiles, .width = @intCast(u32, tilesetSize.w), .height = @intCast(u32, tilesetSize.h), .tileSize = tileSize };
    }

    pub fn dinit(self: *Tileset) void {
        self.tiles.deinit();
    }
};
