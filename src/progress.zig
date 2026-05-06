const std = @import("std");

/// Convert a frame position into normalized progress in the range 0.0...1.0.
///
/// `frame` is the current animation frame and `max_frame` is the frame count
/// that represents completion. The result is clamped so callers can safely pass
/// values beyond the end of an animation.
///
/// A `max_frame` of zero is treated as already complete and returns `1.0`.
pub fn progress(frame: u64, max_frame: u64) f32 {
    if (max_frame == 0) return 1.0;
    if (frame >= max_frame) return 1.0;

    return @as(f32, @floatFromInt(frame)) / @as(f32, @floatFromInt(max_frame));
}

/// Return the looping index for `frame`.
///
/// This is useful when a fixed list of frames should repeat forever, such as
/// spinner glyphs. Empty sequences return zero so callers can decide how to
/// handle missing frame data at the draw site.
pub fn loopIndex(frame: u64, len: usize) usize {
    if (len == 0) return 0;
    return @intCast(frame % len);
}

test "progress returns normalized frame progress" {
    try std.testing.expectEqual(@as(f32, 0.0), progress(0, 10));
    try std.testing.expectEqual(@as(f32, 0.5), progress(5, 10));
    try std.testing.expectEqual(@as(f32, 1.0), progress(10, 10));
}

test "progress clamps frames past the end" {
    try std.testing.expectEqual(@as(f32, 1.0), progress(11, 10));
}

test "progress treats zero max frame as complete" {
    try std.testing.expectEqual(@as(f32, 1.0), progress(0, 0));
    try std.testing.expectEqual(@as(f32, 1.0), progress(5, 0));
}

test "progress treats the first frame as complete for one-frame duration" {
    try std.testing.expectEqual(@as(f32, 1.0), progress(1, 1));
}

test "loopIndex wraps through a fixed length" {
    try std.testing.expectEqual(@as(usize, 0), loopIndex(0, 3));
    try std.testing.expectEqual(@as(usize, 1), loopIndex(1, 3));
    try std.testing.expectEqual(@as(usize, 2), loopIndex(2, 3));
    try std.testing.expectEqual(@as(usize, 0), loopIndex(3, 3));
    try std.testing.expectEqual(@as(usize, 1), loopIndex(4, 3));
}

test "loopIndex handles empty and single-item sequences" {
    try std.testing.expectEqual(@as(usize, 0), loopIndex(0, 0));
    try std.testing.expectEqual(@as(usize, 0), loopIndex(12, 0));
    try std.testing.expectEqual(@as(usize, 0), loopIndex(12, 1));
}
