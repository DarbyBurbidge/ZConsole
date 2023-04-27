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
const Event = @import("../Event/Event.zig").Event;

fn lessThan(context: void, a: Event, b: Event) std.math.Order {
    _ = context;
    return std.math.order(a.priority, b.priority);
}

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
    events: std.PriorityQueue(Event, void, lessThan),

    /// Intializes Game with a Window, Renderer, array of Tilesets, and an array of Views
    ///
    pub fn init(allocator: std.mem.Allocator, window: *Window, renderer: *Renderer, tilesets: []*Tileset, views: []*View) Game {
        const queue = std.PriorityQueue(Event, void, lessThan).init(allocator, undefined);
        return Game{ .window = window, .renderer = renderer, .tilesets = tilesets, .views = views, .quit = false, .events = queue };
    }

    pub fn deinit() !void {}

    pub fn gameLoop(self: *@This()) !void {
        // Wait for signal to close
        while (!self.quit) {
            self.getUserInput();
            self.update();
            self.render();
        }
    }

    fn getUserInput(self: *@This()) void {
        var awaitingInput = true;
        var event: sdl.SDL_Event = undefined;
        while (awaitingInput == true) {
            _ = sdl.SDL_PollEvent(&event);
            if (event.type == sdl.SDL_QUIT) {
                self.quit = true;
                awaitingInput = false;
            }
            if (event.type == sdl.SDL_KEYDOWN) {
                self.handleKeyInput(event);
                awaitingInput = false;
            }
        }
    }

    fn handleKeyInput(self: *@This(), event: sdl.SDL_Event) void {
        print("SDL_EVENT: {}\n", .{event});
        if (event.key.keysym.sym == sdl.SDLK_ESCAPE) self.quit = true;
    }

    pub fn update(self: *@This()) void {
        var iter = self.events.iterator();
        while (iter.next()) |event| {
            self.processEvent(event);
        }
        var tiles = [8]u8{ 196, 218, 179, 191, 196, 192, 179, 217 };
        try self.views[0].setBorders(self.renderer.renderer, self.tilesets[0], &tiles);
    }

    pub fn render(self: *@This()) void {
        for (self.views, 0..) |view, i| {
            // Prepare and render ViewPort
            try Window.prepareTexture(self.renderer.renderer, view.view, &view.size);
            Window.renderTexture(self.renderer.renderer);
            print("View {}\n", .{i});
        }
    }

    fn processEvent(self: *@This(), event: Event) void {
        _ = self;
        print("Event Fired: {}\n", .{event});
    }
};
