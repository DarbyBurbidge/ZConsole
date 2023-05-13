const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});

const Renderer = @import("../Renderer/Renderer.zig").Renderer;
const Rect = @import("../Shapes/Rect.zig");

const TextureOptions = struct {
    texture: ?*sdl.SDL_Texture = null,
};

pub const Texture = struct {
    size: Rect,
    texture: *sdl.SDL_Texture,

    pub fn init(renderer: *Renderer, size: Rect, sdlTexture: TextureOptions) !@This() {
        if (sdlTexture.texture) |texture| {
            var sdlSize = sdl.SDL_Rect{
                .x = 0,
                .y = 0,
                .w = 0,
                .h = 0,
            };
            if (sdl.SDL_QueryTexture(texture, null, null, &sdlSize.w, &sdlSize.h) != 0) return error.UnableToQueryTexture;
            return Texture{
                .size = Rect.fromSDL(sdlSize),
                .texture = texture,
            };
        }
        return Texture{ .size = size, .texture = sdl.SDL_CreateTexture(renderer.renderer, sdl.SDL_PIXELFORMAT_RGBA8888, sdl.SDL_TEXTUREACCESS_TARGET, size.w, size.h) orelse {
            return error.UnableToCreateTexture;
        } };
    }
};
