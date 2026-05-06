pub const frame = @import("frame.zig");
pub const progress_mod = @import("progress.zig");

pub const FrameCounter = frame.FrameCounter;
pub const progress = progress_mod.progress;
pub const loopIndex = progress_mod.loopIndex;
pub const pingPongIndex = progress_mod.pingPongIndex;

test {
    _ = frame;
    _ = progress_mod;
}
