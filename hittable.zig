const interval = @import("interval.zig");
const ray = @import("ray.zig");
const vec3 = @import("vec3.zig");

pub const HitRecord = struct {
    p: vec3.Point3,
    normal: vec3.Vec3,
    t: f64,
    front_face: bool,

    pub fn set_face_normal(
        self: *HitRecord,
        r: *const ray.Ray,
        outward_normal: vec3.Vec3,
    ) void {
        self.front_face = vec3.dot(r.dir, outward_normal) < 0;
        self.normal = if (self.front_face)
            outward_normal
        else
            -outward_normal;
    }
};

pub fn hit(
    object: anytype,
    r: *const ray.Ray,
    ray_t: interval.Interval,
    rec: *HitRecord,
) bool {
    return object.hit(r, ray_t, rec);
}
