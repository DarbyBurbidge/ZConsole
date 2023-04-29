// ZConsole falls under the ZLIB License
// The license can be found in the root directory
// Copyright (c) 2023 DarbyBurbidge

const std = @import("std");
const print = std.debug.print;
const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});

pub const KeyboardEventData = struct {
    type: KeyInputType,
    state: KeyState,
    symbol: KeySymbol, // Keycode
    mod: KeyMod,

    pub fn init(sdlEvent: sdl.SDL_KeyboardEvent) KeyboardEventData {
        return KeyboardEventData{ .type = parseKeyInputType(sdlEvent.type), .state = parseKeyState(sdlEvent.state), .symbol = parseKeySymbol(sdlEvent.keysym.sym), .mod = parseKeyMod(sdlEvent.keysym.mod) };
    }

    fn parseKeyInputType(typeVal: u32) KeyInputType {
        switch (typeVal) {
            sdl.SDL_KEYDOWN => return KeyInputType.KeyDown,
            sdl.SDL_KEYUP => return KeyInputType.KeyUp,
        }
    }

    fn parseKeyState(state: u32) KeyState {
        switch (state) {
            sdl.SDL_PRESSED => return KeyState.Pressed,
            sdl.SDL_RELEASED => return KeyState.Released,
        }
    }

    fn parseKeySymbol(symbol: sdl.SDL_Keycode) KeySymbol {
        switch (symbol.sym) {}
    }

    fn parseKeyMod(mod: u16) KeyMod {
        switch (mod) {}
    }
};

const KeyInputType = enum { KeyDown, KeyUp };

const KeyState = enum { Pressed, Released };

const KeySymbol = enum {};

const KeyMod = enum {};
