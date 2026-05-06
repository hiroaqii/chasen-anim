pub const frame = @import("frame.zig");
pub const progress_mod = @import("progress.zig");

pub const FrameCounter = frame.FrameCounter;
pub const progress = progress_mod.progress;

test {
    _ = frame;
    _ = progress_mod;
}
