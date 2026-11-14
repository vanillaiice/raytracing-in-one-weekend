const std = @import("std");

pub const Vec3 = @Vector(3, f64);
pub const Point3 = Vec3;

pub fn dot(u: Vec3, v: Vec3) f64 {
    return @reduce(.Add, u * v);
}

pub fn length_squared(v: Vec3) f64 {
    return dot(v, v);
}

pub fn length(v: Vec3) f64 {
    return @sqrt(length_squared(v));
}

pub fn cross(u: Vec3, v: Vec3) Vec3 {
    return Vec3{
        u[1] * v[2] - u[2] * v[1],
        u[2] * v[0] - u[0] * v[2],
        u[0] * v[1] - u[1] * v[0],
    };
}

pub fn unit_vector(v: Vec3) Vec3 {
    return v / @as(Vec3, @splat(length(v)));
}
