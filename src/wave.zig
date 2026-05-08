//! Helpers for deterministic wave phases across indexed items.
//!
//! Wave helpers offset each item by a normalized phase amount so rows,
//! columns, or list items can move in sequence while sharing one frame counter.

const std = @import("std");
const blink = @import("blink.zig");
const ease = @import("ease.zig");

/// Return normalized wave phase for one indexed item.
///
/// `frame` and `period` define the shared repeating cycle. `index` selects the
/// item, and `offset` is the normalized phase offset between adjacent items.
///
/// The result is in the range `0.0...1.0`. A period of zero returns `0.0`,
/// even when `offset` is `NaN`. `offset` is clamped into `0.0...1.0`. `NaN`
/// offset values return `NaN` for non-zero periods.
pub fn phase(frame: u64, period: u64, index: u32, offset: f32) f32 {
    if (period == 0) return 0.0;
    if (std.math.isNan(offset)) return offset;

    const base = blink.phase(frame, period);
    const shifted = base + @as(f32, @floatFromInt(index)) * ease.clamp01(offset);
    return wrap01(shifted);
}

fn wrap01(value: f32) f32 {
    return value - @floor(value);
}

test "phase returns base phase for zero offset" {
    try std.testing.expectEqual(@as(f32, 0.0), phase(0, 4, 0, 0.0));
    try std.testing.expectEqual(@as(f32, 0.25), phase(1, 4, 0, 0.0));
    try std.testing.expectEqual(@as(f32, 0.5), phase(2, 4, 99, 0.0));
}

test "phase offsets items by index" {
    try std.testing.expectEqual(@as(f32, 0.0), phase(0, 4, 0, 0.25));
    try std.testing.expectEqual(@as(f32, 0.25), phase(0, 4, 1, 0.25));
    try std.testing.expectEqual(@as(f32, 0.5), phase(0, 4, 2, 0.25));
    try std.testing.expectEqual(@as(f32, 0.75), phase(0, 4, 3, 0.25));
    try std.testing.expectEqual(@as(f32, 0.0), phase(0, 4, 4, 0.25));
    try std.testing.expectEqual(@as(f32, 0.25), phase(0, 4, 5, 0.25));
}

test "phase wraps shifted values" {
    try std.testing.expectEqual(@as(f32, 0.0), phase(3, 4, 1, 0.25));
    try std.testing.expectEqual(@as(f32, 0.25), phase(3, 4, 2, 0.25));
}

test "phase wraps frame periods" {
    try std.testing.expectEqual(@as(f32, 0.0), phase(4, 4, 0, 0.25));
    try std.testing.expectEqual(@as(f32, 0.25), phase(5, 4, 0, 0.25));
}

test "phase handles zero and single-frame periods" {
    try std.testing.expectEqual(@as(f32, 0.0), phase(0, 0, 1, 0.25));
    try std.testing.expectEqual(@as(f32, 0.0), phase(99, 0, 1, 0.25));
    try std.testing.expectEqual(@as(f32, 0.25), phase(99, 1, 1, 0.25));
}

test "phase clamps offset" {
    try std.testing.expectEqual(@as(f32, 0.0), phase(0, 4, 1, -1.0));
    try std.testing.expectEqual(@as(f32, 0.0), phase(0, 4, 1, 1.0));
    try std.testing.expectEqual(@as(f32, 0.0), phase(0, 4, 1, 2.0));
}

test "phase propagates NaN offset" {
    try std.testing.expect(std.math.isNan(phase(0, 4, 1, std.math.nan(f32))));
}

test "phase returns zero when period is zero even with NaN offset" {
    try std.testing.expectEqual(@as(f32, 0.0), phase(0, 0, 1, std.math.nan(f32)));
}
