//! Helpers for deterministic blink periods.
//!
//! Blink helpers convert a frame counter into a repeating phase and an on/off
//! decision. They do not draw, sleep, or schedule frames.

const std = @import("std");
const ease = @import("ease.zig");

/// Return the normalized position inside one blink period.
///
/// The result is in the range `0.0...1.0`. A period of zero returns `0.0`.
pub fn phase(frame: u64, period: u64) f32 {
    if (period == 0) return 0.0;

    const pos = frame % period;
    return @as(f32, @floatFromInt(pos)) / @as(f32, @floatFromInt(period));
}

/// Return whether the blink is on for the given frame.
///
/// `period` is the number of frames in one blink cycle. `duty` is the fraction
/// of each cycle that should be on, clamped into `0.0...1.0`. Period zero and
/// `NaN` duty values return false.
pub fn isOn(frame: u64, period: u64, duty: f32) bool {
    if (period == 0 or std.math.isNan(duty)) return false;
    return phase(frame, period) < ease.clamp01(duty);
}

test "phase returns normalized position inside period" {
    try std.testing.expectEqual(@as(f32, 0.0), phase(0, 4));
    try std.testing.expectEqual(@as(f32, 0.25), phase(1, 4));
    try std.testing.expectEqual(@as(f32, 0.5), phase(2, 4));
    try std.testing.expectEqual(@as(f32, 0.75), phase(3, 4));
}

test "phase wraps at period boundary" {
    try std.testing.expectEqual(@as(f32, 0.0), phase(4, 4));
    try std.testing.expectEqual(@as(f32, 0.25), phase(5, 4));
}

test "phase handles zero and single-frame periods" {
    try std.testing.expectEqual(@as(f32, 0.0), phase(0, 0));
    try std.testing.expectEqual(@as(f32, 0.0), phase(99, 0));
    try std.testing.expectEqual(@as(f32, 0.0), phase(99, 1));
}

test "isOn uses duty fraction" {
    try std.testing.expect(isOn(0, 4, 0.5));
    try std.testing.expect(isOn(1, 4, 0.5));
    try std.testing.expect(!isOn(2, 4, 0.5));
    try std.testing.expect(!isOn(3, 4, 0.5));
}

test "isOn wraps across periods" {
    try std.testing.expect(isOn(4, 4, 0.5));
    try std.testing.expect(isOn(5, 4, 0.5));
    try std.testing.expect(!isOn(6, 4, 0.5));
    try std.testing.expect(!isOn(7, 4, 0.5));
}

test "isOn clamps duty" {
    try std.testing.expect(!isOn(0, 4, -1.0));
    try std.testing.expect(isOn(0, 4, 2.0));
    try std.testing.expect(isOn(3, 4, 2.0));
}

test "isOn handles exact duty boundaries" {
    try std.testing.expect(!isOn(0, 4, 0.0));
    try std.testing.expect(!isOn(3, 4, 0.0));
    try std.testing.expect(isOn(0, 4, 1.0));
    try std.testing.expect(isOn(3, 4, 1.0));
}

test "isOn handles single-frame periods" {
    try std.testing.expect(isOn(0, 1, 0.5));
    try std.testing.expect(isOn(99, 1, 0.5));
    try std.testing.expect(!isOn(99, 1, 0.0));
}

test "isOn treats zero period and NaN duty as off" {
    try std.testing.expect(!isOn(0, 0, 1.0));
    try std.testing.expect(!isOn(0, 4, std.math.nan(f32)));
}
