// ZConsole falls under the ZLIB License
// The license can be found in the root directory
// Copyright (c) 2023 DarbyBurbidge

const print = @import("std").debug.print;

const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});

const KeyboardData = @import("./KeyboardData.zig").KeyboardData;
const MouseClickData = @import("./MouseClickData.zig").MouseClickData;

pub const Event = struct {
    type: EventType,
    data: EventData,

    pub fn keyboard(sdlEvent: sdl.SDL_KeyboardEvent) !Event {
        return Event{
            .type = EventType.Input,
            .data = EventData{ .KeyboardData = try KeyboardData.init(sdlEvent) },
        };
    }

    // fn mouse(sdlEvent: sdl.SDL_MouseButtonEvent) Event{
    //     return Event{

    //     };
    // }
};

pub const EventType = enum { Game, Input };

pub const EventData = union(enum) {
    KeyboardData: KeyboardData,
    MouseClickData: MouseClickData,
};
