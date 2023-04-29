// ZConsole falls under the ZLIB License
// The license can be found in the root directory
// Copyright (c) 2023 DarbyBurbidge

const KeyboardEventData = @import("./KeyboardEventData.zig").KeyboardEventData;

pub const Event = struct {
    priority: u8,
    type: EventType,
    keyboard: ?KeyboardEventData,
    // mouseMove: ?MouseMoveEventData,
    // mouseClick: ?MouseClickEventData,
    // Game: ?GameEventData,

    pub fn Close() Event {
        return Event{ .priority = 0, .type = EventType.Close, .keyboard = undefined };
    }
};

pub const EventType = enum { Keyboard, MouseMove, MouseClick, Game, Close, Null };
