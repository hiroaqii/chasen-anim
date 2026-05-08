pub const frame = @import("frame.zig");
pub const progress_mod = @import("progress.zig");
pub const ease = @import("ease.zig");
pub const transition = @import("transition.zig");
pub const dissolve = @import("dissolve.zig");
pub const sweep = @import("sweep.zig");
pub const stagger = @import("stagger.zig");
pub const blink = @import("blink.zig");

pub const FrameCounter = frame.FrameCounter;
pub const progress = progress_mod.progress;
pub const loopIndex = progress_mod.loopIndex;
pub const pingPongIndex = progress_mod.pingPongIndex;
pub const TransitionKind = transition.TransitionKind;
pub const Transition = transition.Transition;

test {
    _ = frame;
    _ = progress_mod;
    _ = ease;
    _ = transition;
    _ = dissolve;
    _ = sweep;
    _ = stagger;
    _ = blink;
}
