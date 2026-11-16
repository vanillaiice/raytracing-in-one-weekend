const std = @import("std");

const camera = @import("camera.zig");
const hittableList = @import("hittable_list.zig");
const sphere = @import("sphere.zig");
const vec3 = @import("vec3.zig");

pub fn main(init: std.process.Init) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // world
    var world = hittableList.HittableList.init(allocator);
    try world.add(.{ .sphere = sphere.Sphere.init(vec3.Point3{ 0, 0, -1 }, 0.5) });
    try world.add(.{ .sphere = sphere.Sphere.init(vec3.Point3{ 0, -100.5, -1 }, 100) });

    // camera
    const cam = camera.Camera.init(
        16.0 / 9.0,
        400,
    );

    // writer
    const stdout = std.Io.File.stdout();
    var buf: [4096]u8 = undefined;
    var writer = stdout.writer(init.io, &buf);

    // Render
    try cam.render(&world, &writer);
}
