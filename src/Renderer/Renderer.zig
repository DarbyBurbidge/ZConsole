// ZConsole falls under the ZLIB License
// The license can be found in the root directory
// Copyright (c) 2023 DarbyBurbidge

const std = @import("std");

const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});

pub const Renderer = struct {
    renderer: *sdl.SDL_Renderer,
    size: sdl.SDL_Rect,

    pub fn init(window: *sdl.SDL_Window) !Renderer {
        const renderer = sdl.SDL_CreateRenderer(window, -1, sdl.SDL_RENDERER_TARGETTEXTURE) orelse return error.RenderCreate;
        var size = sdl.SDL_Rect{ .x = 0, .y = 0, .w = 0, .h = 0 };
        _ = sdl.SDL_GetRendererOutputSize(renderer, &size.w, &size.h);
        return Renderer{ .renderer = renderer, .size = size };
    }
};
