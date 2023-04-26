const std = @import("std");
const print = std.debug.print;
const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
const Tileset = @import("./ViewPort/Tileset.zig").Tileset;
const GameWindow = @import("./Window/Window.zig").Window;
const GameRenderer = @import("./Renderer/Renderer.zig").Renderer;
const ViewPort = @import("./ViewPort/ViewPort.zig").ViewPort;
const generateStatic = @import("./utils.zig").generateStatic;

pub fn main() !void {
    defer _ = gpa.detectLeaks();
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO) != 0) {
        print("Failed to initialize SDL: {*}\n", .{sdl.SDL_GetError()});
        return error.SDLInitializationFailed;
    }
    defer sdl.SDL_Quit();

    // Create window and renderer
    const gameWindow = try GameWindow.init("My Game");
    const gameRenderer = try GameRenderer.init(allocator, gameWindow.window);

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
    const tileset = try Tileset.init(allocator, gameRenderer.renderer, imageFullPath, 20);
    defer tileset.dinit(allocator);
    print("Main Count: {}\n", .{tileset.tiles.count()});

    // Create ViewPort
    const viewPort = try ViewPort.init(allocator, gameRenderer.renderer, gameRenderer.size.w, @divFloor(gameRenderer.size.h, 2), 20);
    // Generate a bordered rectangle

    print("Main Count: {}\n", .{tileset.tiles.count()});
    var tiles = [8]u8{ 196, 218, 179, 191, 196, 192, 179, 217 };
    try viewPort.setBorders(gameRenderer.renderer, &tileset, &tiles);
    // Prepare and render ViewPort
    try GameWindow.prepareTexture(gameRenderer.renderer, viewPort.view, viewPort.size);
    GameWindow.renderTexture(gameRenderer.renderer);

    // Wait for signal to close
    var event: sdl.SDL_Event = undefined;
    var quit = false;
    while (!quit) {
        while (sdl.SDL_PollEvent(&event) != 0) {
            if (event.type == sdl.SDL_QUIT) {
                quit = true;
            }
        }
    }
    gameRenderer.dinit(allocator);
    viewPort.dinit(allocator);
    std.debug.print("works\n", .{});
}
