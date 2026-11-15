const std = @import("std");

const infinity = std.math.inf(f64);

pub const Interval = struct {
    min: f64 = infinity,
    max: f64 = -infinity,

    pub fn init(min: f64, max: f64) Interval {
        return .{
            .min = min,
            .max = max,
        };
    }

    pub fn size(self: Interval) f64 {
        return self.max - self.min;
    }

    pub fn contains(self: Interval, x: f64) bool {
        return self.min <= x and x <= self.max;
    }

    pub fn surrounds(self: Interval, x: f64) bool {
        return self.min < x and x < self.max;
    }
};

pub const Empty = Interval.init(infinity, -infinity);
pub const Universe = Interval.init(-infinity, infinity);
