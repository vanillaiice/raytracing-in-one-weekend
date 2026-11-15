const std = @import("std");

const constants = @import("constants.zig");
const hittable = @import("hittable.zig");
const hittableList = @import("hittable_list.zig");
const interval = @import("interval.zig");
const ray = @import("ray.zig");
const sphere = @import("sphere.zig");
const vec3 = @import("vec3.zig");

const Color = struct {
    vec: @Vector(3, f64) = undefined,

    pub fn init(r: f64, g: f64, b: f64) Color {
        return .{ .vec = @Vector(3, f64){
            r,
            g,
            b,
        } };
    }

    pub fn write(self: *const Color, writer: *std.Io.Writer) !void {
        const ir: i64 = @intFromFloat(255.999 * self.vec[0]);
        const ig: i64 = @intFromFloat(255.999 * self.vec[1]);
        const ib: i64 = @intFromFloat(255.999 * self.vec[2]);

        try writer.print("{d} {d} {d}\n", .{ ir, ig, ib });
    }

    fn hit_sphere(center: vec3.Point3, radius: f64, r: *const ray.Ray) f64 {
        const oc = center - r.origin;
        const a = vec3.length_squared(r.dir);
        const h = vec3.dot(r.dir, oc);
        const c = vec3.length_squared(oc) - radius * radius;
        const discriminant = h * h - a * c;

        if (discriminant < 0) {
            return -1;
        } else {
            return (h - @sqrt(discriminant)) / a;
        }
    }

    pub fn apply_ray(self: Color, r: *const ray.Ray, world: *hittableList.HittableList) Color {
        _ = self; // autofix

        var rec: hittable.HitRecord = undefined;
        if (world.hit(
            r,
            interval.Interval.init(0, constants.infinity),
            &rec,
        )) {
            const vec = @as(vec3.Vec3, @splat(0.5)) *
                (rec.normal + vec3.Vec3{ 1, 1, 1 });
            return Color{ .vec = vec };
        }

        const unit_direction = vec3.unit_vector(r.dir);
        const a = 0.5 * (unit_direction[1] + 1.0);

        return Color{ .vec = @as(vec3.Vec3, @splat(1 - a)) *
            Color.init(1, 1, 1).vec +
            @as(vec3.Vec3, @splat(a)) *
                Color.init(0.5, 0.7, 1).vec };
    }
};

pub fn main(init: std.process.Init) !void {
    const aspect_ratio: f64 = 16.0 / 9.0;
    const image_width: i32 = 400;

    // calculate image height and ensure at least 1.
    var image_height: i32 = image_width / aspect_ratio;
    if (image_height < 1) {
        image_height = 1;
    }

    // world
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var world = hittableList.HittableList.init(allocator);

    try world.add(.{ .sphere = sphere.Sphere.init(vec3.Point3{ 0, 0, -1 }, 0.5) });
    try world.add(.{ .sphere = sphere.Sphere.init(vec3.Point3{ 0, -100.5, -1 }, 100) });

    // camera
    const focal_length = 1.0;
    const viewport_height = 2.0;
    const viewport_width = viewport_height * (@as(f64, @floatFromInt(image_width)) / image_height);
    const camera_center: vec3.Vec3 = @splat(0);

    // calculate vectors across horizontal and down vertical viewport edges.
    const viewport_u = vec3.Vec3{ viewport_width, 0, 0 };
    const viewport_v = vec3.Vec3{ 0, -viewport_height, 0 };

    // calculate horinzontal and vertical delta from pixel to pixel.
    const pixel_delta_u = viewport_u / @as(vec3.Vec3, @splat(image_width));
    const pixel_delta_v = viewport_v / @as(vec3.Vec3, @splat(image_height));

    // calculate teh location of the upper left pixel.
    const viewport_upper_left = camera_center - vec3.Vec3{ 0, 0, focal_length } - viewport_u / @as(vec3.Vec3, @splat(2)) - viewport_v / @as(vec3.Vec3, @splat(2));
    const pixel00_loc = viewport_upper_left + @as(vec3.Vec3, @splat(0.5)) * (pixel_delta_u + pixel_delta_u);

    const stdout = std.Io.File.stdout();
    var buf: [4096]u8 = undefined;
    var writer = stdout.writer(init.io, &buf);

    // Render

    try writer.interface.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    for (0..@intCast(image_height)) |j| {
        std.debug.print("\rScanlines remaining: {d} ", .{image_height - @as(i32, @intCast(j))});
        for (0..@intCast(image_width)) |i| {
            const pixel_center = pixel00_loc +
                (@as(vec3.Vec3, @splat(@floatFromInt(i))) * pixel_delta_u) +
                (@as(vec3.Vec3, @splat(@floatFromInt(j))) * pixel_delta_v);
            const ray_direction = pixel_center - camera_center;
            const r = ray.Ray.init(camera_center, ray_direction);

            const color = Color.init(0, 0, 0).apply_ray(&r, &world);

            try color.write(&writer.interface);
        }
    }

    try writer.interface.flush();

    std.debug.print("\r\x1b[2KDone.\n", .{});
}
