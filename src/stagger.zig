//! Helpers for staggered progress across indexed items.
//!
//! Staggering offsets each item by a small normalized delay so rows, columns,
//! or list items can start after one another while still using one shared
//! transition progress value.

const std = @import("std");
const ease = @import("ease.zig");

/// Return normalized progress for one staggered item.
///
/// `progress` is the shared animation progress. `index` is the item to compute
/// and `count` is the number of staggered items. `delay` is the normalized
/// offset between adjacent items.
///
/// The returned value is clamped into `0.0...1.0`. Empty counts and
/// out-of-range indices return `0.0`. Delay is clamped so the last item can
/// still start by progress `1.0`. `NaN` inputs propagate through arithmetic and
/// return `NaN`.
pub fn itemProgress(progress: f32, index: u32, count: u32, delay: f32) f32 {
    if (count == 0 or index >= count) return 0.0;

    const clamped_delay = clampedDelay(count, delay);
    const offset = @as(f32, @floatFromInt(index)) * clamped_delay;
    const span = 1.0 - @as(f32, @floatFromInt(count - 1)) * clamped_delay;
    if (span <= 0.0) return if (progress >= offset) 1.0 else 0.0;

    return ease.clamp01((progress - offset) / span);
}

/// Return whether one staggered item has started.
///
/// This is useful when callers only need a boolean reveal decision. Empty
/// counts, out-of-range indices, and `NaN` progress return false.
pub fn isStarted(progress: f32, index: u32, count: u32, delay: f32) bool {
    return itemProgress(progress, index, count, delay) > 0.0;
}

fn clampedDelay(count: u32, delay: f32) f32 {
    if (count <= 1) return 0.0;
    if (std.math.isNan(delay)) return delay;

    const max_delay = 1.0 / @as(f32, @floatFromInt(count - 1));
    return @min(ease.clamp01(delay), max_delay);
}

test "itemProgress returns shared progress when delay is zero" {
    try std.testing.expectEqual(@as(f32, 0.5), itemProgress(0.5, 0, 3, 0.0));
    try std.testing.expectEqual(@as(f32, 0.5), itemProgress(0.5, 1, 3, 0.0));
    try std.testing.expectEqual(@as(f32, 0.5), itemProgress(0.5, 2, 3, 0.0));
}

test "itemProgress treats single item as shared progress" {
    try std.testing.expectEqual(@as(f32, 0.0), itemProgress(0.0, 0, 1, 0.2));
    try std.testing.expectEqual(@as(f32, 0.5), itemProgress(0.5, 0, 1, 0.2));
    try std.testing.expectEqual(@as(f32, 1.0), itemProgress(1.0, 0, 1, 0.2));
}

test "itemProgress staggers items by index" {
    try std.testing.expectEqual(@as(f32, 0.5), itemProgress(0.3, 0, 3, 0.2));
    try std.testing.expectApproxEqAbs(@as(f32, 0.16666667), itemProgress(0.3, 1, 3, 0.2), 0.000001);
    try std.testing.expectEqual(@as(f32, 0.0), itemProgress(0.3, 2, 3, 0.2));
}

test "itemProgress reaches completion for all items at shared progress one" {
    try std.testing.expectEqual(@as(f32, 1.0), itemProgress(1.0, 0, 3, 0.2));
    try std.testing.expectEqual(@as(f32, 1.0), itemProgress(1.0, 1, 3, 0.2));
    try std.testing.expectEqual(@as(f32, 1.0), itemProgress(1.0, 2, 3, 0.2));
}

test "itemProgress clamps progress and delay" {
    try std.testing.expectEqual(@as(f32, 0.0), itemProgress(-1.0, 0, 3, 0.2));
    try std.testing.expectEqual(@as(f32, 1.0), itemProgress(2.0, 0, 3, 0.2));
    try std.testing.expectEqual(@as(f32, 1.0), itemProgress(0.5, 0, 3, 2.0));
}

test "itemProgress handles empty and out-of-range items" {
    try std.testing.expectEqual(@as(f32, 0.0), itemProgress(1.0, 0, 0, 0.2));
    try std.testing.expectEqual(@as(f32, 0.0), itemProgress(1.0, 3, 3, 0.2));
}

test "itemProgress handles saturated stagger spans" {
    try std.testing.expectEqual(@as(f32, 1.0), itemProgress(0.5, 0, 3, 0.6));
    try std.testing.expectEqual(@as(f32, 1.0), itemProgress(0.5, 1, 3, 0.6));
    try std.testing.expectEqual(@as(f32, 0.0), itemProgress(0.5, 2, 3, 0.6));
    try std.testing.expectEqual(@as(f32, 1.0), itemProgress(1.0, 2, 3, 0.6));
}

test "itemProgress propagates NaN progress" {
    try std.testing.expect(std.math.isNan(itemProgress(std.math.nan(f32), 0, 3, 0.2)));
}

test "itemProgress propagates NaN delay" {
    try std.testing.expect(std.math.isNan(itemProgress(0.5, 0, 3, std.math.nan(f32))));
}

test "isStarted returns whether item progress is above zero" {
    try std.testing.expect(isStarted(0.3, 0, 3, 0.2));
    try std.testing.expect(isStarted(0.3, 1, 3, 0.2));
    try std.testing.expect(!isStarted(0.3, 2, 3, 0.2));
    try std.testing.expect(!isStarted(1.0, 3, 3, 0.2));
    try std.testing.expect(!isStarted(std.math.nan(f32), 0, 3, 0.2));
    try std.testing.expect(!isStarted(0.5, 0, 3, std.math.nan(f32)));
}
