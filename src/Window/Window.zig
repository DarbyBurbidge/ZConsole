const std = @import("std");

const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});

const print = std.debug.print;

pub const Window = struct {
    window: *sdl.SDL_Window,

    pub fn prepareTexture(renderer: *sdl.SDL_Renderer, texture: *sdl.SDL_Texture, textureContext: *sdl.SDL_Rect) !void {
        // Render to screen
        _ = sdl.SDL_RenderCopy(renderer, texture, null, textureContext);
    }

    pub fn renderTexture(renderer: *sdl.SDL_Renderer) void {
        sdl.SDL_RenderPresent(renderer);
    }

    pub fn init(title: [*c]const u8) !Window {
        const window = sdl.SDL_CreateWindow(title, sdl.SDL_WINDOWPOS_CENTERED, sdl.SDL_WINDOWPOS_CENTERED, 0, 0, sdl.SDL_WINDOW_FULLSCREEN_DESKTOP) orelse return error.FailedToCreateWindow;

        return Window{ .window = window };
    }
};
