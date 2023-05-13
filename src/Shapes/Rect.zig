const sdl = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_image.h");
});

x: u16,
y: u16,
w: u16,
h: u16,

pub fn toSDL(self: *@This()) sdl.SDL_Rect {
    return sdl.SDL_Rect{
        .x = @as(c_int, self.x),
        .y = @as(c_int, self.y),
        .w = @as(c_int, self.w),
        .h = @as(c_int, self.h),
    };
}

pub fn fromSDL(rect: sdl.SDL_Rect) @This() {
    return @This(){ .x = @truncate(u16, @intCast(u32, rect.x)), .y = @truncate(u16, @intCast(u32, rect.y)), .w = @truncate(u16, @intCast(u32, rect.w)), .h = @truncate(u16, @intCast(u32, rect.h)) };
}
