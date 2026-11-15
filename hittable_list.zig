const std = @import("std");

const hittable = @import("hittable.zig");
const interval = @import("interval.zig");
const ray = @import("ray.zig");
const sphere = @import("sphere.zig");

pub const HittableType = union(enum) {
    sphere: sphere.Sphere,
};

pub const HittableList = struct {
    allocator: std.mem.Allocator,
    objects: std.ArrayList(HittableType),

    pub fn init(allocator: std.mem.Allocator) HittableList {
        return .{
            .allocator = allocator,
            .objects = .empty,
        };
    }

    pub fn deinit(self: *HittableList) void {
        self.objects.deinit(self.allocator);
    }

    pub fn add(self: *HittableList, h: HittableType) !void {
        try self.objects.append(self.allocator, h);
    }

    pub fn hit(
        self: HittableList,
        r: *const ray.Ray,
        ray_t: interval.Interval,
        rec: *hittable.HitRecord,
    ) bool {
        var temp_rec: hittable.HitRecord = undefined;
        var hit_anything = false;
        var closest_so_far = ray_t.max;

        for (self.objects.items) |*i| {
            switch (i.*) {
                .sphere => |*s| {
                    if (s.hit(r, interval.Interval.init(ray_t.min, closest_so_far), &temp_rec)) {
                        hit_anything = true;
                        closest_so_far = temp_rec.t;
                        rec.* = temp_rec;
                    }
                },
            }
        }

        return hit_anything;
    }
};
