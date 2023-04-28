const std = @import("std");
const print = std.debug.print;
const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
const Game = @import("./Game/Game.zig").Game;
const Tileset = @import("./View/Tileset.zig").Tileset;
const Window = @import("./Window/Window.zig").Window;
const Renderer = @import("./Renderer/Renderer.zig").Renderer;
const View = @import("./View/View.zig").View;
const Event = @import("./Event/Event.zig").Event;
const generateStatic = @import("./utils.zig").generateStatic;

pub fn main() !void {
    defer _ = gpa.detectLeaks();
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
        print("Failed to initialize SDL: {*}\n", .{sdl.SDL_GetError()});
        return error.SDLInitializationFailed;
    }
    defer sdl.SDL_Quit();

    // Create window and renderer
    var window = try Window.init("My Game");
    var renderer = try Renderer.init(window.window);

    const rootDir = std.mem.span(sdl.SDL_GetBasePath());
    print("{s}\n", .{rootDir});
    const imagePath = "../img/ascii_tiles.png";
    print("{s}\n", .{imagePath});
    const combinedLen = rootDir.len + imagePath.len + 1;
    const imageFullPath = try allocator.alloc(u8, combinedLen);
    std.mem.copy(u8, imageFullPath[0..rootDir.len], rootDir[0..]);
    std.mem.copy(u8, imageFullPath[rootDir.len..], imagePath);
    imageFullPath[combinedLen - 1] = 0;
    print("{s}\n", .{@ptrCast([*c]const u8, imageFullPath)});
    defer allocator.free(imageFullPath);

    // Create tileset from filepath
    var tileset = try Tileset.init(allocator, renderer.renderer, imageFullPath, 20);
    defer tileset.dinit();
    print("Main Count: {}\n", .{tileset.tiles.count()});

    // Create ViewPort that covers the top half of the screen
    var view = try View.init(renderer.renderer, 0, 0, renderer.size.w, @divFloor(renderer.size.h, 2), 20);
    // Create array of all tilesets and views
    var tilesets = [_]*Tileset{&tileset};
    var views = [_]*View{&view};
    // Initialize game
    var eventMap = std.AutoHashMap(sdl.SDL_EventType, *const fn (sdlEvent: sdl.SDL_Event) []Event).init(allocator);

    try eventMap.put(sdl.SDL_KEYDOWN, &exit);
    defer eventMap.deinit();
    var game = Game.init(allocator, &window, &renderer, &tilesets, &views, &eventMap);
    try game.gameLoop();

    std.debug.print("works\n", .{});
}

fn exit(sdlEvent: sdl.SDL_Event) []Event {
    if (sdlEvent.key.keysym.sym == sdl.SDLK_ESCAPE) {
        return &[_]Event{
            Event.Exit(),
        };
    }
    return &[_]Event{};
}
