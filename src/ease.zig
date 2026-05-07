//! Easing helpers for normalized animation progress.
//!
//! Easing functions take a progress value, clamp non-NaN inputs into
//! `0.0...1.0`, and return a transformed progress value in the same range.
//! This keeps callers from repeating range checks before every easing call.
//!
//! `NaN` is not handled specially. Because comparisons with `NaN` are false,
//! `clamp01` returns it unchanged and easing functions propagate it through
//! their normal arithmetic.

const std = @import("std");

/// Clamp a normalized animation value into the range 0.0...1.0.
///
/// Easing functions generally expect progress values in this range. Keeping
/// the clamp here lets callers pass slightly out-of-range values without
/// repeating the same guard at every call site.
pub fn clamp01(value: f32) f32 {
    if (value <= 0.0) return 0.0;
    if (value >= 1.0) return 1.0;
    return value;
}

/// Constant-speed easing.
///
/// `linear` returns the clamped input unchanged, so 0.25 stays 0.25 and 0.75
/// stays 0.75. This is useful as the baseline easing behavior and as a default
/// when no acceleration or deceleration is desired.
pub fn linear(t: f32) f32 {
    return clamp01(t);
}

/// Quadratic ease-in.
///
/// `inQuad` starts slowly and accelerates toward the end by squaring the
/// clamped input progress.
pub fn inQuad(t: f32) f32 {
    const p = clamp01(t);
    return p * p;
}

/// Quadratic ease-out.
///
/// `outQuad` starts quickly and slows toward the end by applying the quadratic
/// curve to the remaining progress.
pub fn outQuad(t: f32) f32 {
    const p = clamp01(t);
    const remaining = 1.0 - p;
    return 1.0 - remaining * remaining;
}

/// Quadratic ease-in-out.
///
/// `inOutQuad` starts slowly, speeds up near the middle, and slows again near
/// the end by using an ease-in curve for the first half and an ease-out curve
/// for the second half.
pub fn inOutQuad(t: f32) f32 {
    const p = clamp01(t);
    if (p < 0.5) {
        return 2.0 * p * p;
    }

    const remaining = -2.0 * p + 2.0;
    return 1.0 - remaining * remaining / 2.0;
}

test "clamp01 clamps values into normalized range" {
    try std.testing.expectEqual(@as(f32, 0.0), clamp01(-1.0));
    try std.testing.expectEqual(@as(f32, 0.0), clamp01(0.0));
    try std.testing.expectEqual(@as(f32, 0.5), clamp01(0.5));
    try std.testing.expectEqual(@as(f32, 1.0), clamp01(1.0));
    try std.testing.expectEqual(@as(f32, 1.0), clamp01(2.0));
}

test "linear returns clamped input" {
    try std.testing.expectEqual(@as(f32, 0.0), linear(-1.0));
    try std.testing.expectEqual(@as(f32, 0.25), linear(0.25));
    try std.testing.expectEqual(@as(f32, 0.75), linear(0.75));
    try std.testing.expectEqual(@as(f32, 1.0), linear(2.0));
}

test "inQuad starts slowly and accelerates" {
    try std.testing.expectEqual(@as(f32, 0.0), inQuad(-1.0));
    try std.testing.expectEqual(@as(f32, 0.0), inQuad(0.0));
    try std.testing.expectEqual(@as(f32, 0.25), inQuad(0.5));
    try std.testing.expectEqual(@as(f32, 1.0), inQuad(1.0));
    try std.testing.expectEqual(@as(f32, 1.0), inQuad(2.0));
}

test "outQuad starts quickly and slows down" {
    try std.testing.expectEqual(@as(f32, 0.0), outQuad(-1.0));
    try std.testing.expectEqual(@as(f32, 0.0), outQuad(0.0));
    try std.testing.expectEqual(@as(f32, 0.75), outQuad(0.5));
    try std.testing.expectEqual(@as(f32, 1.0), outQuad(1.0));
    try std.testing.expectEqual(@as(f32, 1.0), outQuad(2.0));
}

test "inOutQuad eases in and then out" {
    try std.testing.expectEqual(@as(f32, 0.0), inOutQuad(-1.0));
    try std.testing.expectEqual(@as(f32, 0.0), inOutQuad(0.0));
    try std.testing.expectEqual(@as(f32, 0.125), inOutQuad(0.25));
    try std.testing.expectEqual(@as(f32, 0.5), inOutQuad(0.5));
    try std.testing.expectEqual(@as(f32, 0.875), inOutQuad(0.75));
    try std.testing.expectEqual(@as(f32, 1.0), inOutQuad(1.0));
    try std.testing.expectEqual(@as(f32, 1.0), inOutQuad(2.0));
}
