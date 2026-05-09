//! Helpers for deterministic pulse values.
//!
//! Pulse helpers convert a frame counter into a repeating `0.0...1.0...0.0`
//! value. They are useful for breathing highlights, selection emphasis, and
//! other effects where a value should rise and fall over time.

const std = @import("std");
const blink = @import("blink.zig");
const ease = @import("ease.zig");

/// Return a triangle pulse value for one frame.
///
/// `period` is the number of frames in one full pulse cycle. The returned
/// value rises from `0.0` toward `1.0` in the first half of the period, then
/// falls back toward `0.0` in the second half. A period of zero returns `0.0`.
pub fn value(frame: u64, period: u64) f32 {
    return valueFromPhase(blink.phase(frame, period));
}

/// Return a triangle pulse value for a normalized phase.
///
/// `phase` is clamped into `0.0...1.0`. Non-NaN inputs return a value in the
/// same range. `NaN` is not handled specially and propagates through the
/// arithmetic.
pub fn valueFromPhase(phase: f32) f32 {
    const p = ease.clamp01(phase);
    if (p <= 0.5) return p * 2.0;
    return (1.0 - p) * 2.0;
}

test "value rises then falls inside one period" {
    try std.testing.expectEqual(@as(f32, 0.0), value(0, 4));
    try std.testing.expectEqual(@as(f32, 0.5), value(1, 4));
    try std.testing.expectEqual(@as(f32, 1.0), value(2, 4));
    try std.testing.expectEqual(@as(f32, 0.5), value(3, 4));
}

test "value wraps at period boundary" {
    try std.testing.expectEqual(@as(f32, 0.0), value(4, 4));
    try std.testing.expectEqual(@as(f32, 0.5), value(5, 4));
}

test "value handles odd periods without an exact peak frame" {
    try std.testing.expectApproxEqAbs(@as(f32, 0.0), value(0, 5), 0.0001);
    try std.testing.expectApproxEqAbs(@as(f32, 0.4), value(1, 5), 0.0001);
    try std.testing.expectApproxEqAbs(@as(f32, 0.8), value(2, 5), 0.0001);
    try std.testing.expectApproxEqAbs(@as(f32, 0.8), value(3, 5), 0.0001);
    try std.testing.expectApproxEqAbs(@as(f32, 0.4), value(4, 5), 0.0001);
}

test "value handles zero and single-frame periods" {
    try std.testing.expectEqual(@as(f32, 0.0), value(0, 0));
    try std.testing.expectEqual(@as(f32, 0.0), value(99, 0));
    try std.testing.expectEqual(@as(f32, 0.0), value(99, 1));
}

test "valueFromPhase clamps non-NaN inputs" {
    try std.testing.expectEqual(@as(f32, 0.0), valueFromPhase(-1.0));
    try std.testing.expectEqual(@as(f32, 0.0), valueFromPhase(0.0));
    try std.testing.expectEqual(@as(f32, 0.5), valueFromPhase(0.25));
    try std.testing.expectEqual(@as(f32, 1.0), valueFromPhase(0.5));
    try std.testing.expectEqual(@as(f32, 0.5), valueFromPhase(0.75));
    try std.testing.expectEqual(@as(f32, 0.0), valueFromPhase(1.0));
    try std.testing.expectEqual(@as(f32, 0.0), valueFromPhase(2.0));
}

test "valueFromPhase propagates NaN" {
    try std.testing.expect(std.math.isNan(valueFromPhase(std.math.nan(f32))));
}
