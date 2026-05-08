const std = @import("std");
const anim = @import("chasen_anim");

const period: u64 = 6;
const duty: f32 = 0.5;
const last_frame: u64 = 12;

// This example shows how blink helpers turn a frame counter into a repeating
// phase and on/off decision. chasen-anim only returns values; the app chooses
// what to draw while the blink is on or off.
pub fn main() void {
    std.debug.print("frame phase on  row\n", .{});

    var frame: u64 = 0;
    while (frame <= last_frame) : (frame += 1) {
        const p = anim.blink.phase(frame, period);
        const on = anim.blink.isOn(frame, period, duty);

        std.debug.print("{d:>5} {d:>5.3} {s:<5} ", .{
            frame,
            p,
            if (on) "true" else "false",
        });
        printRow(on);
    }
}

fn printRow(on: bool) void {
    const glyph: u8 = if (on) '#' else '.';

    var i: usize = 0;
    while (i < 8) : (i += 1) {
        std.debug.print("{c}", .{glyph});
    }
    std.debug.print("\n", .{});
}
