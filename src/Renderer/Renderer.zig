// ZConsole falls under the ZLIB License
// The license can be found in the root directory
// Copyright (c) 2023 DarbyBurbidge

const std = @import("std");

const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});

const View = @import("../View/View.zig").View;
const Texture = @import("./Texture.zig").Texture;
const Rect = @import("../Shapes/Rect.zig");

pub const RenderCopyOptions = struct { fromSize: ?*Rect = null, toSize: ?*Rect = null };

pub const Renderer = struct {
    renderer: *sdl.SDL_Renderer,
    size: Rect,

    pub fn init(window: *sdl.SDL_Window) !Renderer {
        const renderer = sdl.SDL_CreateRenderer(window, -1, sdl.SDL_RENDERER_TARGETTEXTURE) orelse return error.RenderCreate;
        var size = sdl.SDL_Rect{ .x = 0, .y = 0, .w = 0, .h = 0 };
        _ = sdl.SDL_GetRendererOutputSize(renderer, &size.w, &size.h);
        return Renderer{ .renderer = renderer, .size = Rect.fromSDL(size) };
    }

    // Default target is Window, but this allows targeting a View
    pub fn blit(self: *@This(), target: Texture, texture: Texture, options: RenderCopyOptions) !void {
        try self.setRenderTarget(target);
        try self.render(texture, options);
        if (sdl.SDL_SetRenderTarget(self.renderer, null) != 0) return error.CouldNotResetRenderTarget;
    }

    fn setRenderTarget(self: *@This(), target: Texture) !void {
        if (sdl.SDL_SetRenderTarget(self.renderer, target.texture) != 0) {
            return error.InvalidRenderTarget;
        }
    }

    pub fn render(self: *@This(), texture: Texture, options: RenderCopyOptions) !void {
        var sdl_size = sdl.SDL_Rect{ .x = texture.size.x, .y = texture.size.y, .w = texture.size.w, .h = texture.size.h };
        if (sdl.SDL_RenderCopy(self.renderer, texture.texture, if (options.fromSize) |fromSize| &fromSize.toSDL() else null, if (options.toSize) |toSize| &toSize.toSDL() else &sdl_size) != 0) return error.CouldNotRenderTexture;
    }
};
