const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});
const Errors = @import("../errors.zig");

const print = std.debug.print;

const TilesetError = error{ TextureLoad, TileLoad, TileTransfer };

pub const Tileset = struct {
    tileset: *sdl.SDL_Texture,
    tiles: std.AutoHashMap(u8, *sdl.SDL_Texture),
    tileSize: u8,
    width: u32,
    height: u32,

    pub fn getTile(self: @This(), tile: u8) !*sdl.SDL_Texture {
        print("Get Tile: {}, Count: {}\n", .{ tile, self.tiles.count() });
        return self.tiles.get(tile) orelse undefined;
    }

    fn setTileset(renderer: ?*sdl.SDL_Renderer, path: []const u8) !*sdl.SDL_Texture {
        if (sdl.IMG_Init(sdl.IMG_INIT_PNG) == 0) {
            print("Failed to initialize SDL_Image: {*}\n", .{sdl.IMG_GetError()});
            return error.SDLInitializationFailed;
        }
        defer sdl.IMG_Quit();

        const texture = sdl.IMG_LoadTexture(renderer, @ptrCast([*c]const u8, path)) orelse {
            print("{*}", .{sdl.IMG_GetError()});
            return TilesetError.TextureLoad;
        };
        return texture;
    }

    fn setTiles(renderer: *sdl.SDL_Renderer, tileset: *sdl.SDL_Texture, tileSize: u8, tileMap: *std.AutoHashMap(u8, *sdl.SDL_Texture)) !void {
        var textureSize = sdl.SDL_Rect{
            .x = 0,
            .y = 0,
            .w = 0,
            .h = 0,
        };
        _ = sdl.SDL_QueryTexture(tileset, null, null, &textureSize.w, &textureSize.h);
        const rows: u8 = @truncate(u8, @intCast(u32, @divFloor(textureSize.h, tileSize)));
        const cols: u8 = @truncate(u8, @intCast(u32, @divFloor(textureSize.w, tileSize)));
        var idx: u16 = 0;
        for (0..rows) |row| {
            for (0..cols) |col| {
                const tileRect = sdl.SDL_Rect{
                    .x = @truncate(u16, col) * tileSize,
                    .y = @truncate(u16, row) * tileSize,
                    .w = tileSize,
                    .h = tileSize,
                };
                const tileSurface = try createTileTexture(renderer, tileset, &tileRect);

                try tileMap.put(@truncate(u8, idx), tileSurface);
                idx += 1;
            }
        }
        print("{}", .{tileMap.count()});
    }

    fn createTileTexture(renderer: *sdl.SDL_Renderer, src: *sdl.SDL_Texture, tileRect: *const sdl.SDL_Rect) !*sdl.SDL_Texture {
        const newTile = sdl.SDL_CreateTexture(renderer, sdl.SDL_PIXELFORMAT_RGBA8888, sdl.SDL_TEXTUREACCESS_TARGET, tileRect.w, tileRect.h) orelse return error.CreationFailed;
        if (sdl.SDL_SetRenderTarget(renderer, newTile) != 0) {
            return Errors.Renderer.RenderTarget;
        }

        _ = sdl.SDL_RenderCopy(renderer, src, tileRect, null);
        if (sdl.SDL_SetRenderTarget(renderer, null) != 0) {
            return Errors.Renderer.RenderTarget;
        }

        return newTile;
    }

    pub fn init(allocator: std.mem.Allocator, renderer: *sdl.SDL_Renderer, path: []const u8, tileSize: u8) !Tileset {
        if (renderer == undefined) {
            return error.MissingRenderer;
        }
        var tiles = std.AutoHashMap(u8, *sdl.SDL_Texture).init(allocator);
        const tileset = try setTileset(renderer, path);
        try setTiles(renderer, tileset, tileSize, &tiles);
        print("Init scope Count: {}", .{tiles.count()});
        var tilesetSize = sdl.SDL_Rect{ .x = 0, .y = 0, .w = 0, .h = 0 };
        _ = sdl.SDL_QueryTexture(tileset, null, null, &tilesetSize.w, &tilesetSize.h);
        return Tileset{ .tileset = tileset, .tiles = tiles, .width = @intCast(u32, tilesetSize.w), .height = @intCast(u32, tilesetSize.h), .tileSize = tileSize };
    }

    pub fn dinit(self: *Tileset) void {
        sdl.SDL_DestroyTexture(self.tileset);
        for (0..self.tiles.count()) |i| {
            sdl.SDL_DestroyTexture(self.tiles.get(@truncate(u8, i)));
        }
        self.tiles.deinit();
    }
};
