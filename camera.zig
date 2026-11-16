const std = @import("std");

const color = @import("color.zig");
const constants = @import("constants.zig");
const hittable = @import("hittable.zig");
const hittableList = @import("hittable_list.zig");
const interval = @import("interval.zig");
const ray = @import("ray.zig");
const vec3 = @import("vec3.zig");

pub const Camera = struct {
    aspect_ratio: f64 = 1,
    image_width: i32 = 100,

    image_height: i32 = undefined,
    center: vec3.Point3 = undefined,
    pixel00_loc: vec3.Point3 = undefined,
    pixel_delta_u: vec3.Vec3 = undefined,
    pixel_delta_v: vec3.Vec3 = undefined,

    pub fn init(aspect_ratio: f64, image_width: i32) Camera {
        var camera = Camera{
            .aspect_ratio = aspect_ratio,
            .image_width = image_width,
        };

        camera.image_height = @intFromFloat(@as(f64, @floatFromInt(camera.image_width)) / camera.aspect_ratio);
        if (camera.image_height < 1) {
            camera.image_height = 1;
        }

        camera.center = @splat(0);

        // camera
        const focal_length = 1.0;
        const viewport_height = 2.0;
        const viewport_width = viewport_height * (@as(f64, @floatFromInt(camera.image_width)) / camera.image_height);

        // calculate vectors across horizontal and down vertical viewport edges.
        const viewport_u = vec3.Vec3{ viewport_width, 0, 0 };
        const viewport_v = vec3.Vec3{ 0, -viewport_height, 0 };

        // calculate horinzontal and vertical delta from pixel to pixel.
        camera.pixel_delta_u = viewport_u / @as(vec3.Vec3, @splat(camera.image_width));
        camera.pixel_delta_v = viewport_v / @as(vec3.Vec3, @splat(camera.image_height));

        // calculate teh location of the upper left pixel.
        const viewport_upper_left = camera.center - vec3.Vec3{ 0, 0, focal_length } - viewport_u / @as(vec3.Vec3, @splat(2)) - viewport_v / @as(vec3.Vec3, @splat(2));
        camera.pixel00_loc = viewport_upper_left + @as(vec3.Vec3, @splat(0.5)) * (camera.pixel_delta_u + camera.pixel_delta_u);

        return camera;
    }

    pub fn render(self: *const Camera, world: *hittableList.HittableList, writer: *std.Io.File.Writer) !void {
        try writer.interface.print("P3\n{d} {d}\n255\n", .{ self.image_width, self.image_height });

        for (0..@intCast(self.image_height)) |j| {
            std.debug.print("\rScanlines remaining: {d} ", .{self.image_height - @as(i32, @intCast(j))});

            for (0..@intCast(self.image_width)) |i| {
                const pixel_center = self.pixel00_loc +
                    (@as(vec3.Vec3, @splat(@floatFromInt(i))) * self.pixel_delta_u) +
                    (@as(vec3.Vec3, @splat(@floatFromInt(j))) * self.pixel_delta_v);
                const ray_direction = pixel_center - self.center;
                const r = ray.Ray.init(self.center, ray_direction);

                const c = self.ray_color(&r, world);

                try c.write(&writer.interface);
            }
        }

        try writer.interface.flush();

        std.debug.print("\r\x1b[2KDone.\n", .{});
    }

    fn ray_color(self: Camera, r: *const ray.Ray, world: *hittableList.HittableList) color.Color {
        _ = self; // autofix

        var rec: hittable.HitRecord = undefined;

        if (world.hit(
            r,
            interval.Interval.init(0, constants.infinity),
            &rec,
        )) {
            const vec = @as(vec3.Vec3, @splat(0.5)) *
                (rec.normal + vec3.Vec3{ 1, 1, 1 });
            return color.Color{ .vec = vec };
        }

        const unit_direction = vec3.unit_vector(r.dir);
        const a = 0.5 * (unit_direction[1] + 1.0);

        return color.Color{ .vec = @as(vec3.Vec3, @splat(1 - a)) *
            color.Color.init(1, 1, 1).vec +
            @as(vec3.Vec3, @splat(a)) *
                color.Color.init(0.5, 0.7, 1).vec };
    }
};
