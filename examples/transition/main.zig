const std = @import("std");
const anim = @import("chasen_anim");

// This example prints a small transition timeline.
// chasen-anim does not draw frames or schedule ticks by itself; the app owns
// that loop and asks chasen-anim for deterministic values each step.
pub fn main() void {
    var transition = anim.Transition.init(.fade, 8);

    std.debug.print("frame progress eased done\n", .{});

    while (true) {
        const p = transition.progress();
        const eased = anim.ease.outQuad(p);

        std.debug.print("{d:>5} {d:>8.3} {d:>5.3} {}\n", .{
            transition.frame,
            p,
            eased,
            transition.done(),
        });

        if (transition.done()) break;
        _ = transition.step();
    }
}
