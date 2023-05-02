// ZConsole falls under the ZLIB License
// The license can be found in the root directory
// Copyright (c) 2023 DarbyBurbidge

const std = @import("std");
const print = std.debug.print;
const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});
const Allocator = std.mem.Allocator;
const Window = @import("../Window/Window.zig").Window;
const Renderer = @import("../Renderer/Renderer.zig").Renderer;
const Tileset = @import("../View/Tileset.zig").Tileset;
const View = @import("../View/View.zig").View;
const InputManager = @import("../Input/InputManager.zig").InputManager;
const Event = @import("../Input/Event.zig").Event;
const EventType = @import("../Input/Event.zig").EventType;
const KeySymbol = @import("../Input/KeyboardData.zig").KeySymbol;
const KeyState = @import("../Input/KeyboardData.zig").KeyState;

// fn lessThan(context: void, a: Event, b: Event) std.math.Order {
//     _ = context;
//     return std.math.order(a.data.priority, b.data.priority);
// }

/// The core Game object. Handles the main game loop
/// calls Input handler which bubbles up a list of game events
/// updates Game entities based on the events
/// then sends those updates to the renderer
pub const Game = struct {
    window: *Window,
    renderer: *Renderer,
    tilesets: []*Tileset,
    views: []*View,

    quit: bool,
    //events: std.PriorityQueue(Event, void, lessThan),
    eventMap: *std.AutoHashMap(sdl.SDL_EventType, *const fn (event: sdl.SDL_Event) []Event),

    /// Intializes Game
    /// returns: Game{.window, .renderer, .tilesets, .views, .quit: bool, .events: PriorityQueue}
    pub fn init(allocator: std.mem.Allocator, window: *Window, renderer: *Renderer, tilesets: []*Tileset, views: []*View, eventMap: *std.AutoHashMap(sdl.SDL_EventType, *const fn (event: sdl.SDL_Event) []Event)) Game {
        _ = allocator;
        //const queue = std.PriorityQueue(Event, void, lessThan).init(allocator, undefined);
        return Game{ .window = window, .renderer = renderer, .tilesets = tilesets, .views = views, .quit = false, .eventMap = eventMap };
    }

    pub fn deinit(self: *@This()) void {
        _ = self;
        //self.events.deinit();
    }

    /// Starts the game loop
    /// calls getUserInput(), update(), render()
    /// in that order
    pub fn gameLoop(self: *@This()) !void {
        // Wait for signal to close
        while (!self.quit) {
            try self.input();
            self.update();
            self.render();
        }
    }

    fn input(self: *@This()) !void {
        var awaitingInput = true;
        while (awaitingInput == true) {
            if (InputManager.getInputEvent()) |event| {
                const gameEvent = self.processInput(event);
                awaitingInput = false;
                print("GameEvent: {?}", .{gameEvent});
            }
        }
    }

    pub fn update(self: *@This()) void {
        _ = self;
        // var iter = self.events.iterator();
        // _ = iter;
        // // while (iter.next()) |event| {
        // //     self.processGameEvent(event.data);
        // // }
        // var tiles = [8]u8{ 196, 218, 179, 191, 196, 192, 179, 217 };
        // try self.views[0].setBorders(self.renderer.renderer, self.tilesets[0], &tiles);
    }

    pub fn render(self: *@This()) void {
        for (self.views, 0..) |view, i| {
            // Prepare and render ViewPort
            try Window.prepareTexture(self.renderer.renderer, view.view, &view.size);
            Window.renderTexture(self.renderer.renderer);
            print("View {}\n", .{i});
        }
    }

    fn processInput(self: *Game, event: Event) ?Event {
        if (event.type != EventType.Input) {
            return undefined;
        }
        switch (event.data) {
            .KeyboardData => |data| {
                switch (data.symbol) {
                    KeySymbol.ESCAPE => self.quit = true,
                    else => if (data.state != KeyState.RELEASED) print("Key: State: {} Symbol: {} Mod: {?}\n", .{ data.state, data.symbol, data.mod }),
                }
                return undefined;
            },
            else => {
                return undefined;
            },
        }
    }
};
