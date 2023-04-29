const std = @import("std");

const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.zig");
});
