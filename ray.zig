const vec3 = @import("vec3.zig");

pub const Ray = struct {
    origin: vec3.Point3,
    dir: vec3.Vec3,

    pub fn init(origin: vec3.Vec3, dir: vec3.Vec3) Ray {
        return .{
            .origin = origin,
            .dir = dir,
        };
    }

    pub fn at(self: *const Ray, t: f64) vec3.Point3 {
        return self.origin + @as(vec3.Vec3, @splat(t)) * self.dir;
    }
};
