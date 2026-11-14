const std = @import("std");
pub const pi = std.math.pi;

pub const infinity = std.math.inf(f64);

pub fn degrees_to_radians(degrees: f64) f64 {
    return degrees * pi / 180;
}
