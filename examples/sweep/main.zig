const std = @import("std");
const anim = @import("chasen_anim");

const width: u32 = 12;
const height: u32 = 4;
const max_frame: u64 = 6;

// This example shows how sweep helpers turn transition progress into a
// deterministic column reveal. chasen-anim only answers whether each column is
// active; the app chooses the glyphs, rows, and drawing surface.
pub fn main() void {
    printDirection(.left_to_right);
    std.debug.print("\n", .{});
    printDirection(.right_to_left);
}

fn printDirection(direction: anim.sweep.Direction) void {
    var transition = anim.Transition.init(.sweep, max_frame);

    std.debug.print("{s}\n", .{labelFor(direction)});

    while (true) {
        const p = transition.progress();

        std.debug.print("frame {d} progress {d:.3}\n", .{ transition.frame, p });
        printGrid(p, direction);

        if (transition.done()) break;
        _ = transition.step();
        std.debug.print("\n", .{});
    }
}

fn printGrid(progress: f32, direction: anim.sweep.Direction) void {
    var row: u32 = 0;
    while (row < height) : (row += 1) {
        var col: u32 = 0;
        while (col < width) : (col += 1) {
            const glyph: u8 = if (anim.sweep.isColumnActive(width, col, progress, direction)) '#' else '.';
            std.debug.print("{c}", .{glyph});
        }
        std.debug.print("\n", .{});
    }
}

fn labelFor(direction: anim.sweep.Direction) []const u8 {
    return switch (direction) {
        .left_to_right => "left_to_right",
        .right_to_left => "right_to_left",
    };
}
