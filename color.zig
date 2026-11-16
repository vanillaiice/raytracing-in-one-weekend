const std = @import("std");

const vec3 = @import("vec3.zig");

pub const Color = struct {
    vec: @Vector(3, f64) = undefined,

    pub fn init(r: f64, g: f64, b: f64) Color {
        return .{ .vec = vec3.Vec3{
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
};
