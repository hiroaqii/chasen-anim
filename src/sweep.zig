//! Helpers for deterministic sweep-style reveal order.
//!
//! A sweep transition reveals columns in one direction. These helpers map a
//! column coordinate to a normalized threshold so callers can compare it with
//! transition progress.

const std = @import("std");
const ease = @import("ease.zig");

/// Direction used when converting a column into sweep order.
pub const Direction = enum {
    /// Reveal lower columns first.
    left_to_right,

    /// Reveal higher columns first.
    right_to_left,
};

/// Return the normalized progress required for one column to become active.
///
/// The result is in the range `0.0...1.0`. The first column in the chosen
/// direction becomes active after the first width-sized progress step.
/// Empty widths return `1.0`. Out-of-range columns are clamped to the last
/// column before applying the direction.
pub fn columnThreshold(width: u32, col: u32, direction: Direction) f32 {
    if (width == 0) return 1.0;

    const clamped_col = @min(col, width - 1);
    const order_index = switch (direction) {
        .left_to_right => clamped_col,
        .right_to_left => width - 1 - clamped_col,
    };

    return @as(f32, @floatFromInt(order_index + 1)) / @as(f32, @floatFromInt(width));
}

/// Return whether a column should be active for the given progress.
///
/// `progress` is clamped into `0.0...1.0` before comparison. Out-of-range
/// columns and empty widths are inactive. `NaN` propagates through the clamp
/// and makes the comparison false.
pub fn isColumnActive(width: u32, col: u32, progress: f32, direction: Direction) bool {
    if (width == 0 or col >= width) return false;
    return columnThreshold(width, col, direction) <= ease.clamp01(progress);
}

test "columnThreshold returns left to right thresholds" {
    try std.testing.expectEqual(@as(f32, 0.25), columnThreshold(4, 0, .left_to_right));
    try std.testing.expectEqual(@as(f32, 0.5), columnThreshold(4, 1, .left_to_right));
    try std.testing.expectEqual(@as(f32, 0.75), columnThreshold(4, 2, .left_to_right));
    try std.testing.expectEqual(@as(f32, 1.0), columnThreshold(4, 3, .left_to_right));
}

test "columnThreshold returns right to left thresholds" {
    try std.testing.expectEqual(@as(f32, 1.0), columnThreshold(4, 0, .right_to_left));
    try std.testing.expectEqual(@as(f32, 0.75), columnThreshold(4, 1, .right_to_left));
    try std.testing.expectEqual(@as(f32, 0.5), columnThreshold(4, 2, .right_to_left));
    try std.testing.expectEqual(@as(f32, 0.25), columnThreshold(4, 3, .right_to_left));
}

test "columnThreshold handles empty and out-of-range columns" {
    try std.testing.expectEqual(@as(f32, 1.0), columnThreshold(0, 0, .left_to_right));
    try std.testing.expectEqual(@as(f32, 1.0), columnThreshold(1, 0, .left_to_right));
    try std.testing.expectEqual(@as(f32, 1.0), columnThreshold(1, 0, .right_to_left));
    try std.testing.expectEqual(@as(f32, 1.0), columnThreshold(4, 99, .left_to_right));
    try std.testing.expectEqual(@as(f32, 0.25), columnThreshold(4, 99, .right_to_left));
}

test "isColumnActive compares column threshold with clamped progress" {
    try std.testing.expect(!isColumnActive(4, 0, 0.0, .left_to_right));
    try std.testing.expect(isColumnActive(4, 0, 0.25, .left_to_right));
    try std.testing.expect(isColumnActive(4, 1, 0.5, .left_to_right));
    try std.testing.expect(!isColumnActive(4, 2, 0.5, .left_to_right));
    try std.testing.expect(isColumnActive(4, 3, 2.0, .left_to_right));
}

test "isColumnActive handles right to left direction" {
    try std.testing.expect(isColumnActive(4, 3, 0.25, .right_to_left));
    try std.testing.expect(isColumnActive(4, 2, 0.5, .right_to_left));
    try std.testing.expect(!isColumnActive(4, 1, 0.5, .right_to_left));
}

test "isColumnActive handles single-column and completed progress" {
    try std.testing.expect(!isColumnActive(1, 0, 0.0, .left_to_right));
    try std.testing.expect(isColumnActive(1, 0, 1.0, .left_to_right));

    try std.testing.expect(isColumnActive(4, 0, 1.0, .left_to_right));
    try std.testing.expect(isColumnActive(4, 1, 1.0, .left_to_right));
    try std.testing.expect(isColumnActive(4, 2, 1.0, .left_to_right));
    try std.testing.expect(isColumnActive(4, 3, 1.0, .left_to_right));
}

test "isColumnActive treats empty, out-of-range, and NaN progress as inactive" {
    try std.testing.expect(!isColumnActive(0, 0, 1.0, .left_to_right));
    try std.testing.expect(!isColumnActive(4, 4, 1.0, .left_to_right));
    try std.testing.expect(!isColumnActive(4, 0, std.math.nan(f32), .left_to_right));
}
