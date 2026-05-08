//! Helpers for deterministic dissolve-style reveal order.
//!
//! A dissolve transition reveals cells in a scattered but stable order. These
//! helpers map a seed and cell coordinate to a normalized threshold so callers
//! can compare it with transition progress.

const std = @import("std");
const ease = @import("ease.zig");

/// Return a stable normalized threshold for one cell.
///
/// The result is in the range `0.0...1.0`. Cells with lower thresholds become
/// active earlier when compared with increasing transition progress.
pub fn threshold(seed: u64, col: u32, row: u32) f32 {
    const bits: u32 = @intCast(mix(seed, col, row) >> 40);
    return @as(f32, @floatFromInt(bits)) / @as(f32, @floatFromInt(0xFF_FFFF));
}

/// Return whether a cell should be active for the given progress.
///
/// `progress` is clamped into `0.0...1.0` before comparison. `NaN` propagates
/// through the clamp and makes the comparison false.
pub fn isActive(seed: u64, col: u32, row: u32, progress: f32) bool {
    return threshold(seed, col, row) <= ease.clamp01(progress);
}

fn mix(seed: u64, col: u32, row: u32) u64 {
    var value = seed ^ 0xD1B5_4A32_D192_ED03;
    value ^= @as(u64, col) *% 0x9E37_79B9_7F4A_7C15;
    value = mix64(value);
    value ^= @as(u64, row) *% 0xBF58_476D_1CE4_E5B9;
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

test "threshold is deterministic for the same seed and coordinate" {
    try std.testing.expectEqual(
        threshold(42, 8, 3),
        threshold(42, 8, 3),
    );
}

test "threshold changes with seed and coordinate" {
    const base = threshold(42, 8, 3);

    try std.testing.expect(base != threshold(43, 8, 3));
    try std.testing.expect(base != threshold(42, 9, 3));
    try std.testing.expect(base != threshold(42, 8, 4));
}

test "threshold returns normalized values" {
    const values = [_]f32{
        threshold(0, 0, 0),
        threshold(1, 1, 1),
        threshold(42, 8, 3),
        threshold(std.math.maxInt(u64), std.math.maxInt(u32), std.math.maxInt(u32)),
    };

    for (values) |value| {
        try std.testing.expect(value >= 0.0);
        try std.testing.expect(value <= 1.0);
    }
}

test "threshold avoids exact zero for the default seed and origin" {
    try std.testing.expect(threshold(0, 0, 0) > 0.0);
}

test "isActive compares threshold with clamped progress" {
    const seed = 42;
    const col = 8;
    const row = 3;
    const t = threshold(seed, col, row);

    try std.testing.expect(!isActive(seed, col, row, t - 0.001));
    try std.testing.expect(isActive(seed, col, row, t));
    try std.testing.expect(isActive(seed, col, row, 2.0));
    try std.testing.expect(!isActive(seed, col, row, -1.0));
}

test "isActive treats NaN progress as inactive" {
    try std.testing.expect(!isActive(42, 8, 3, std.math.nan(f32)));
}
