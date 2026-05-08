//! Helpers for deterministic glitch probability.
//!
//! Glitch helpers decide whether a cell should temporarily show a noisy
//! fragment. They mix a seed, frame, and coordinate into a stable normalized
//! sample and compare it with a caller-provided probability.

const std = @import("std");
const ease = @import("ease.zig");

/// Return a deterministic normalized sample for one cell at one frame.
///
/// The result is in the range `0.0...1.0`. The same seed, frame, and coordinate
/// always return the same sample.
pub fn sample(seed: u64, frame: u64, col: u32, row: u32) f32 {
    const bits: u32 = @intCast(mix(seed, frame, col, row) >> 40);
    return @as(f32, @floatFromInt(bits)) / @as(f32, @floatFromInt(0xFF_FFFF));
}

/// Return whether a cell should be glitched for the given probability.
///
/// `probability` is clamped into `0.0...1.0`. `NaN` probability values return
/// false. A probability of `1.0` always returns true.
pub fn isActive(seed: u64, frame: u64, col: u32, row: u32, probability: f32) bool {
    if (std.math.isNan(probability)) return false;

    const p = ease.clamp01(probability);
    if (p <= 0.0) return false;
    if (p >= 1.0) return true;
    return sample(seed, frame, col, row) < p;
}

fn mix(seed: u64, frame: u64, col: u32, row: u32) u64 {
    var value = seed ^ 0xA076_1D64_78BD_642F;
    value ^= frame *% 0xE703_7ED1_A0B4_28DB;
    value = mix64(value);
    value ^= @as(u64, col) *% 0x8EBC_6AF0_9C88_C6E3;
    value = mix64(value);
    value ^= @as(u64, row) *% 0x5899_65CC_7537_4CC3;
    return mix64(value);
}

fn mix64(input: u64) u64 {
    var value = input;
    value ^= value >> 30;
    value *%= 0xBF58_476D_1CE4_E5B9;
    value ^= value >> 27;
    value *%= 0x94D0_49BB_1331_11EB;
    value ^= value >> 31;
    return value;
}

test "sample is deterministic for the same seed frame and coordinate" {
    try std.testing.expectEqual(
        sample(42, 7, 8, 3),
        sample(42, 7, 8, 3),
    );
}

test "sample changes with seed frame and coordinate" {
    const base = sample(42, 7, 8, 3);

    try std.testing.expect(base != sample(43, 7, 8, 3));
    try std.testing.expect(base != sample(42, 8, 8, 3));
    try std.testing.expect(base != sample(42, 7, 9, 3));
    try std.testing.expect(base != sample(42, 7, 8, 4));
}

test "sample returns normalized values" {
    const values = [_]f32{
        sample(0, 0, 0, 0),
        sample(1, 1, 1, 1),
        sample(42, 7, 8, 3),
        sample(std.math.maxInt(u64), std.math.maxInt(u64), std.math.maxInt(u32), std.math.maxInt(u32)),
    };

    for (values) |value| {
        try std.testing.expect(value >= 0.0);
        try std.testing.expect(value <= 1.0);
    }
}

test "sample avoids exact zero for default inputs" {
    try std.testing.expect(sample(0, 0, 0, 0) > 0.0);
}

test "isActive compares sample with clamped probability" {
    const seed = 42;
    const frame = 7;
    const col = 8;
    const row = 3;
    const s = sample(seed, frame, col, row);

    try std.testing.expect(!isActive(seed, frame, col, row, s));
    try std.testing.expect(isActive(seed, frame, col, row, s + 0.001));
    try std.testing.expect(isActive(seed, frame, col, row, 2.0));
    try std.testing.expect(!isActive(seed, frame, col, row, -1.0));
}

test "isActive handles exact probability boundaries" {
    try std.testing.expect(!isActive(42, 7, 8, 3, 0.0));
    try std.testing.expect(!isActive(42, 7, 8, 4, 0.0));
    try std.testing.expect(isActive(42, 7, 8, 3, 1.0));
    try std.testing.expect(isActive(42, 7, 8, 4, 1.0));
}

test "isActive treats zero probability and NaN as inactive" {
    try std.testing.expect(!isActive(42, 7, 8, 3, 0.0));
    try std.testing.expect(!isActive(42, 7, 8, 3, std.math.nan(f32)));
}
