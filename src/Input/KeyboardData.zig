// ZConsole falls under the ZLIB License
// The license can be found in the root directory
// Copyright (c) 2023 DarbyBurbidge

const std = @import("std");
const print = std.debug.print;
const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});

pub const KeyboardData = struct {
    type: KeyInputType,
    state: KeyState,
    symbol: KeySymbol, // Keycode
    mod: ?KeyMod,

    pub fn init(sdlEvent: sdl.SDL_KeyboardEvent) !KeyboardData {
        return KeyboardData{ .type = try parseKeyInputType(sdlEvent.type), .state = try parseKeyState(sdlEvent.state), .symbol = try parseKeySymbol(sdlEvent.keysym.sym), .mod = try parseKeyMod(sdlEvent.keysym.mod) };
    }

    fn parseKeyInputType(typeVal: u32) !KeyInputType {
        switch (typeVal) {
            sdl.SDL_KEYDOWN => return KeyInputType.KEYDOWN,
            sdl.SDL_KEYUP => return KeyInputType.KEYUP,
            else => return error.CantParseKeyInput,
        }
    }

    fn parseKeyState(state: u32) !KeyState {
        switch (state) {
            sdl.SDL_PRESSED => return KeyState.PRESSED,
            sdl.SDL_RELEASED => return KeyState.RELEASED,
            else => return error.CannotParseKeyState,
        }
    }

    fn parseKeySymbol(symbol: sdl.SDL_Keycode) !KeySymbol {
        switch (symbol) {
            // Keys 0-9
            sdl.SDLK_0 => return KeySymbol.K0,
            sdl.SDLK_1 => return KeySymbol.K1,
            sdl.SDLK_2 => return KeySymbol.K2,
            sdl.SDLK_3 => return KeySymbol.K3,
            sdl.SDLK_4 => return KeySymbol.K4,
            sdl.SDLK_5 => return KeySymbol.K5,
            sdl.SDLK_6 => return KeySymbol.K6,
            sdl.SDLK_7 => return KeySymbol.K7,
            sdl.SDLK_8 => return KeySymbol.K8,
            sdl.SDLK_9 => return KeySymbol.K9,
            // Numpad Keys
            sdl.SDLK_KP_0 => return KeySymbol.N0,
            sdl.SDLK_KP_1 => return KeySymbol.N1,
            sdl.SDLK_KP_2 => return KeySymbol.N2,
            sdl.SDLK_KP_3 => return KeySymbol.N3,
            sdl.SDLK_KP_4 => return KeySymbol.N4,
            sdl.SDLK_KP_5 => return KeySymbol.N5,
            sdl.SDLK_KP_6 => return KeySymbol.N6,
            sdl.SDLK_KP_7 => return KeySymbol.N7,
            sdl.SDLK_KP_8 => return KeySymbol.N8,
            sdl.SDLK_KP_9 => return KeySymbol.N9,
            // Escape and F1-12 keys
            sdl.SDLK_ESCAPE => return KeySymbol.ESCAPE,

            sdl.SDLK_F1 => return KeySymbol.F1,
            sdl.SDLK_F2 => return KeySymbol.F2,
            sdl.SDLK_F3 => return KeySymbol.F3,
            sdl.SDLK_F4 => return KeySymbol.F4,
            sdl.SDLK_F5 => return KeySymbol.F5,
            sdl.SDLK_F6 => return KeySymbol.F6,
            sdl.SDLK_F7 => return KeySymbol.F7,
            sdl.SDLK_F8 => return KeySymbol.F8,
            sdl.SDLK_F9 => return KeySymbol.F9,
            sdl.SDLK_F10 => return KeySymbol.F10,
            sdl.SDLK_F11 => return KeySymbol.F11,
            sdl.SDLK_F12 => return KeySymbol.F12,
            // Arrow Keys
            sdl.SDLK_UP => return KeySymbol.UP,
            sdl.SDLK_DOWN => return KeySymbol.DOWN,
            sdl.SDLK_LEFT => return KeySymbol.LEFT,
            sdl.SDLK_RIGHT => return KeySymbol.RIGHT,
            // Brackets & Braces
            sdl.SDLK_LEFTBRACKET => return KeySymbol.L_BRACKET,
            sdl.SDLK_RIGHTBRACKET => return KeySymbol.R_BRACKET,
            // sdl.SDLK_LEFTBRACE => return KeySymbol.L_BRACE,
            // sdl.SDLK_RIGHTBRACE => return KeySymbol.R_BRACE,
            sdl.SDLK_LEFTPAREN => return KeySymbol.L_PAREN,
            sdl.SDLK_RIGHTPAREN => return KeySymbol.R_PAREN,
            // Alphabet Keys
            sdl.SDLK_a => return KeySymbol.A,
            sdl.SDLK_b => return KeySymbol.B,
            sdl.SDLK_c => return KeySymbol.C,
            sdl.SDLK_d => return KeySymbol.D,
            sdl.SDLK_e => return KeySymbol.E,
            sdl.SDLK_f => return KeySymbol.F,
            sdl.SDLK_g => return KeySymbol.G,
            sdl.SDLK_h => return KeySymbol.H,
            sdl.SDLK_i => return KeySymbol.I,
            sdl.SDLK_j => return KeySymbol.J,
            sdl.SDLK_k => return KeySymbol.K,
            sdl.SDLK_l => return KeySymbol.L,
            sdl.SDLK_m => return KeySymbol.M,
            sdl.SDLK_n => return KeySymbol.N,
            sdl.SDLK_o => return KeySymbol.O,
            sdl.SDLK_p => return KeySymbol.P,
            sdl.SDLK_q => return KeySymbol.Q,
            sdl.SDLK_r => return KeySymbol.R,
            sdl.SDLK_s => return KeySymbol.S,
            sdl.SDLK_t => return KeySymbol.T,
            sdl.SDLK_u => return KeySymbol.U,
            sdl.SDLK_v => return KeySymbol.V,
            sdl.SDLK_w => return KeySymbol.W,
            sdl.SDLK_x => return KeySymbol.X,
            sdl.SDLK_y => return KeySymbol.Y,
            sdl.SDLK_z => return KeySymbol.Z,
            // Top row symbols (missing parens)
            sdl.SDLK_BACKQUOTE => return KeySymbol.BACKTICK,
            sdl.SDLK_EXCLAIM => return KeySymbol.EXCLAIM,
            sdl.SDLK_AT => return KeySymbol.AT,
            sdl.SDLK_HASH => return KeySymbol.HASH,
            sdl.SDLK_DOLLAR => return KeySymbol.DOLLAR,
            sdl.SDLK_PERCENT => return KeySymbol.PERCENT,
            sdl.SDLK_CARET => return KeySymbol.CARET,
            sdl.SDLK_AMPERSAND => return KeySymbol.AMPERSAND,
            sdl.SDLK_ASTERISK => return KeySymbol.ASTERISK,
            sdl.SDLK_MINUS => return KeySymbol.MINUS,
            sdl.SDLK_UNDERSCORE => return KeySymbol.UNDERSCORE,
            sdl.SDLK_EQUALS => return KeySymbol.EQUALS,
            sdl.SDLK_PLUS => return KeySymbol.PLUS,
            sdl.SDLK_BACKSPACE => return KeySymbol.BACKSPACE,
            // Other symbols
            sdl.SDLK_BACKSLASH => return KeySymbol.BACKSLASH,
            sdl.SDLK_SEMICOLON => return KeySymbol.SEMICOLON,
            sdl.SDLK_COLON => return KeySymbol.COLON,
            sdl.SDLK_QUOTE => return KeySymbol.QUOTE,
            sdl.SDLK_QUOTEDBL => return KeySymbol.QUOTEDBL,
            sdl.SDLK_COMMA => return KeySymbol.COMMA,
            sdl.SDLK_GREATER => return KeySymbol.GREATER,
            sdl.SDLK_PERIOD => return KeySymbol.PERIOD,
            sdl.SDLK_LESS => return KeySymbol.LESSER,
            sdl.SDLK_SLASH => return KeySymbol.SLASH,
            sdl.SDLK_QUESTION => return KeySymbol.QUESTION,
            // Action Keys or Mod Keys
            sdl.SDLK_NUMLOCKCLEAR => return KeySymbol.NUMLCK,
            sdl.SDLK_CAPSLOCK => return KeySymbol.CAPSLCK,
            sdl.SDLK_AUDIOMUTE => return KeySymbol.AUDIOMUTE,
            sdl.SDLK_TAB => return KeySymbol.TAB,
            //sdl.SDLK_a => return KeySymbol.SHIFT,
            //sdl.SDLK_a => return KeySymbol.CTRL,
            //sdl.SDLK_a => return KeySymbol.ALT,
            sdl.SDLK_RETURN, sdl.SDLK_RETURN2 => return KeySymbol.RETURN,
            sdl.SDLK_SPACE => return KeySymbol.SPACE,
            else => return error.CantParseKeySymbol,
        }
    }

    fn parseKeyMod(keyMod: ?u16) !?KeyMod {
        while (keyMod) |mod| {
            switch (mod) {
                sdl.KMOD_NONE => return KeyMod.NONE,
                sdl.KMOD_LCTRL, sdl.KMOD_RCTRL, sdl.KMOD_CTRL => return KeyMod.CTRL,
                sdl.KMOD_LSHIFT, sdl.KMOD_RSHIFT, sdl.KMOD_SHIFT => return KeyMod.SHIFT,
                sdl.KMOD_LALT, sdl.KMOD_RALT, sdl.KMOD_ALT => return KeyMod.ALT,
                else => return error.CannotParseKeyMod,
            }
        } else {
            return undefined;
        }
    }
};

pub const KeyInputType = enum { KEYDOWN, KEYUP };

pub const KeyState = enum { PRESSED, RELEASED };

pub const KeySymbol = enum {
    // Keys 0-9
    K0,
    K1,
    K2,
    K3,
    K4,
    K5,
    K6,
    K7,
    K8,
    K9,
    // Numpad Keys
    N0,
    N1,
    N2,
    N3,
    N4,
    N5,
    N6,
    N7,
    N8,
    N9,
    // Escape and F1-12 keys
    ESCAPE,
    F1,
    F2,
    F3,
    F4,
    F5,
    F6,
    F7,
    F8,
    F9,
    F10,
    F11,
    F12,
    // Arrow Keys
    UP,
    DOWN,
    LEFT,
    RIGHT,
    // Brackets & Braces
    L_BRACKET,
    R_BRACKET,
    L_BRACE,
    R_BRACE,
    L_PAREN,
    R_PAREN,
    // Alphabet Keys
    A,
    B,
    C,
    D,
    E,
    F,
    G,
    H,
    I,
    J,
    K,
    L,
    M,
    N,
    O,
    P,
    Q,
    R,
    S,
    T,
    U,
    V,
    W,
    X,
    Y,
    Z,
    // Top row symbols (missing parens)
    BACKTICK,
    EXCLAIM,
    AT,
    HASH,
    DOLLAR,
    PERCENT,
    CARET,
    AMPERSAND,
    ASTERISK,
    MINUS,
    UNDERSCORE,
    EQUALS,
    PLUS,
    BACKSPACE,
    // Other symbols
    BACKSLASH,
    SEMICOLON,
    COLON,
    QUOTE,
    QUOTEDBL,
    COMMA,
    GREATER,
    PERIOD,
    LESSER,
    SLASH,
    QUESTION,
    // Action Keys or Mod Keys
    NUMLCK,
    CAPSLCK,
    AUDIOMUTE,
    TAB,
    SHIFT,
    CTRL,
    ALT,
    RETURN,
    SPACE,
};

pub const KeyMod = enum {
    NONE,
    NUM,
    CAPS,
    CTRL,
    SHIFT,
    ALT,
};
