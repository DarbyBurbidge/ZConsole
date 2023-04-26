const std = @import("std");

const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});

pub const Renderer = struct {
    renderer: *sdl.SDL_Renderer,
    size: *sdl.SDL_Rect,

    pub fn init(allocator: std.mem.Allocator, window: *sdl.SDL_Window) !Renderer {
        const renderer = sdl.SDL_CreateRenderer(window, -1, sdl.SDL_RENDERER_TARGETTEXTURE) orelse return error.RenderCreate;
        const size = try allocator.create(sdl.SDL_Rect);
        size.x = 0;
        size.y = 0;
        _ = sdl.SDL_GetRendererOutputSize(renderer, &size.*.w, &size.*.h);
        return Renderer{ .renderer = renderer, .size = size };
    }

    pub fn dinit(self: @This(), allocator: std.mem.Allocator) void {
        allocator.destroy(self.size);
    }
};
