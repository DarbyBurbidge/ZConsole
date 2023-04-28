// ZConsole falls under the ZLIB License
// The license can be found in the root directory
// Copyright (c) 2023 DarbyBurbidge

pub const Event = struct {
    priority: u8,
    type: EventType,

    pub fn Exit() Event {
        return Event{ .priority = 0, .type = EventType.Exit };
    }

    pub fn Null() Event {
        return Event{ .priority = 1000, .type = EventType.Null };
    }
};

pub const EventType = enum {
    Exit,
    Null,
};
