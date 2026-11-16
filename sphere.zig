const hittable = @import("hittable.zig");
const interval = @import("interval.zig");
const ray = @import("ray.zig");
const vec3 = @import("vec3.zig");

pub const Sphere = struct {
    center: vec3.Point3,
    radius: f64,

    pub fn init(center: vec3.Point3, radius: f64) Sphere {
        return .{
            .center = center,
            .radius = radius,
        };
    }

    pub fn hit(
        self: *const Sphere,
        r: *const ray.Ray,
        ray_t: interval.Interval,
        rec: *hittable.HitRecord,
    ) bool {
        const oc = self.center - r.origin;
        const a = vec3.length_squared(r.dir);
        const h = vec3.dot(r.dir, oc);
        const c = vec3.length_squared(oc) - self.radius * self.radius;

        const discriminant = h * h - a * c;
        if (discriminant < 0) {
            return false;
        }

        const sqrtd = @sqrt(discriminant);

        var root = (h - sqrtd) / a;
        if (!ray_t.surrounds(root)) {
            root = (h + sqrtd) / a;
            if (!ray_t.surrounds(root)) {
                return false;
            }
        }

        rec.t = root;
        rec.p = r.at(rec.t);

        const outward_normal = (rec.p - self.center) / @as(vec3.Vec3, @splat(self.radius));
        rec.set_face_normal(r, outward_normal);

        return true;
    }
};
