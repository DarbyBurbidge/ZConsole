const std = @import("std");

const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.zig");
});

const Event = @import("../Event/Event.zig").Event;

pub const Keyboard = struct { keys: std.AutoHashMap(sdl.SDL_EventType, Event.Keyboard) };
