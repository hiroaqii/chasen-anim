const std = @import("std");
const anim = @import("chasen_anim");

const period: u64 = 8;
const offset: f32 = 0.125;
const items: u32 = 6;
const width: usize = 16;
const last_frame: u64 = 8;

// This example shows how wave helpers turn one frame counter into per-item
// phases. chasen-anim returns the phase only; the app chooses how to convert it
// into glyphs, positions, or colors.
pub fn main() void {
    var frame: u64 = 0;
    while (frame <= last_frame) : (frame += 2) {
        std.debug.print("frame {d}\n", .{frame});
        printItems(frame);
        if (frame != last_frame) std.debug.print("\n", .{});
    }
}

fn printItems(frame: u64) void {
    var index: u32 = 0;
    while (index < items) : (index += 1) {
        const p = anim.wave.phase(frame, period, index, offset);
        std.debug.print("item {d} phase {d:.3} ", .{ index, p });
        printMarker(p);
    }
}

fn printMarker(phase: f32) void {
    const marker = phaseToIndex(phase);

    var col: usize = 0;
    while (col < width) : (col += 1) {
        const glyph: u8 = if (col == marker) '#' else '.';
        std.debug.print("{c}", .{glyph});
    }
    std.debug.print("\n", .{});
}

fn phaseToIndex(phase: f32) usize {
    const raw = @as(usize, @intFromFloat(phase * @as(f32, @floatFromInt(width))));
    return @min(raw, width - 1);
}
