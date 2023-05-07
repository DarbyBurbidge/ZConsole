const print = @import("std").debug.print;
const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});

const Event = @import("./Event.zig").Event;

/// The InputManagers responsibility is to take SDL_Keyboard and
/// SDL_MouseButton events and convert them into ZConsole Events
pub const InputManager = struct {
    pub fn getInputEvent() ?Event {
        var sdlEvent: sdl.SDL_Event = undefined;
        while (sdl.SDL_PollEvent(&sdlEvent) != 0) {
            if (sdlEvent.type == sdl.SDL_KEYDOWN) {
                return Event.keyboard(sdlEvent.key) catch |err| {
                    print("Unable to parse Input Event: {?}", .{err});
                    return undefined;
                };
            } else if (sdlEvent.type == sdl.SDL_MOUSEBUTTONDOWN) {
                return undefined; //Event.mouseClick(sdlEvent);
            }
        }
        return undefined;
    }
};
