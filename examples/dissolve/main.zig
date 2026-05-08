const std = @import("std");
const anim = @import("chasen_anim");

const seed: u64 = 42;
const width: u32 = 16;
const height: u32 = 6;
const max_frame: u64 = 8;

// This example shows how dissolve helpers turn transition progress into a
// deterministic scattered reveal. chasen-anim only answers whether each cell is
// active; the app chooses the actual glyphs and drawing surface.
pub fn main() void {
    var transition = anim.Transition.init(.dissolve, max_frame);

    while (true) {
        const p = transition.progress();

        std.debug.print("frame {d} progress {d:.3}\n", .{ transition.frame, p });
        printGrid(p);

        if (transition.done()) break;
        _ = transition.step();
        std.debug.print("\n", .{});
    }
}

fn printGrid(progress: f32) void {
    var row: u32 = 0;
    while (row < height) : (row += 1) {
        var col: u32 = 0;
        while (col < width) : (col += 1) {
            const glyph: u8 = if (anim.dissolve.isActive(seed, col, row, progress)) '#' else '.';
            std.debug.print("{c}", .{glyph});
        }
        std.debug.print("\n", .{});
    }
}
