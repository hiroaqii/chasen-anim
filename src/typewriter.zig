//! Helpers for typewriter-style reveal counts.
//!
//! Typewriter helpers convert normalized progress into the number of visible
//! items. They do not inspect strings, split graphemes, measure cell widths, or
//! choose what to render.

const std = @import("std");
const ease = @import("ease.zig");

/// Return how many items should be visible for the given progress.
///
/// `progress` is clamped into `0.0...1.0`, then mapped to a count in
/// `0...total`. A progress of `1.0` always returns `total`. Empty totals and
/// `NaN` progress return `0`. Very large totals are limited by `f32` progress
/// precision; this helper is intended for UI-sized item counts.
pub fn visibleCount(progress: f32, total: usize) usize {
    if (total == 0 or std.math.isNan(progress)) return 0;

    const p = ease.clamp01(progress);
    if (p <= 0.0) return 0;
    if (p >= 1.0) return total;

    const visible_float = @floor(p * @as(f32, @floatFromInt(total)));
    const visible: usize = @intFromFloat(visible_float);
    return @min(visible, total);
}

test "visibleCount maps progress to visible item count" {
    try std.testing.expectEqual(@as(usize, 0), visibleCount(0.0, 4));
    try std.testing.expectEqual(@as(usize, 1), visibleCount(0.25, 4));
    try std.testing.expectEqual(@as(usize, 2), visibleCount(0.5, 4));
    try std.testing.expectEqual(@as(usize, 3), visibleCount(0.75, 4));
    try std.testing.expectEqual(@as(usize, 4), visibleCount(1.0, 4));
}

test "visibleCount clamps progress" {
    try std.testing.expectEqual(@as(usize, 0), visibleCount(-1.0, 4));
    try std.testing.expectEqual(@as(usize, 4), visibleCount(2.0, 4));
}

test "visibleCount returns total only at completed progress" {
    try std.testing.expectEqual(@as(usize, 2), visibleCount(0.99, 3));
    try std.testing.expectEqual(@as(usize, 3), visibleCount(1.0, 3));
}

test "visibleCount advances at floor thresholds" {
    try std.testing.expectEqual(@as(usize, 0), visibleCount(0.249, 4));
    try std.testing.expectEqual(@as(usize, 1), visibleCount(0.25, 4));
}

test "visibleCount handles empty total and NaN progress" {
    try std.testing.expectEqual(@as(usize, 0), visibleCount(1.0, 0));
    try std.testing.expectEqual(@as(usize, 0), visibleCount(std.math.nan(f32), 4));
}

test "visibleCount handles single item" {
    try std.testing.expectEqual(@as(usize, 0), visibleCount(0.0, 1));
    try std.testing.expectEqual(@as(usize, 0), visibleCount(0.5, 1));
    try std.testing.expectEqual(@as(usize, 1), visibleCount(1.0, 1));
}
