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
