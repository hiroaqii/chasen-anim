const std = @import("std");

/// Monotonically increasing frame counter for deterministic animation steps.
///
/// `FrameCounter` stores only a frame number. It does not know about wall-clock
/// time, timers, `ctx.frame().request()`, or any Chasen runtime state. The app or
/// runtime decides when an animation tick happens, then calls `step()` once for
/// that tick.
///
/// This keeps animation helpers deterministic: the same sequence of `step()`
/// calls always produces the same frame numbers. Higher-level code can then use
/// `frame` for spinner indices, looping animations, blink phases, or transition
/// progress.
pub const FrameCounter = struct {
    /// Current frame number.
    ///
    /// The default value is zero, which represents an animation that has not
    /// advanced yet.
    frame: u64 = 0,

    /// Advance by one frame and return the new frame number.
    ///
    /// The increment is saturating. If the counter reaches `u64` max, further
    /// calls stay at that value instead of wrapping back to zero.
    pub fn step(self: *FrameCounter) u64 {
        self.frame +|= 1;
        return self.frame;
    }

    /// Reset the frame number to zero.
    ///
    /// Use this when restarting an animation from the beginning.
    pub fn reset(self: *FrameCounter) void {
        self.frame = 0;
    }
};

test "FrameCounter starts at zero and advances" {
    var counter: FrameCounter = .{};

    try std.testing.expectEqual(@as(u64, 0), counter.frame);
    try std.testing.expectEqual(@as(u64, 1), counter.step());
    try std.testing.expectEqual(@as(u64, 2), counter.step());
}

test "FrameCounter reset returns to zero" {
    var counter: FrameCounter = .{ .frame = 42 };

    counter.reset();

    try std.testing.expectEqual(@as(u64, 0), counter.frame);
}

test "FrameCounter saturates at u64 max" {
    var counter: FrameCounter = .{ .frame = std.math.maxInt(u64) };

    try std.testing.expectEqual(std.math.maxInt(u64), counter.step());
    try std.testing.expectEqual(std.math.maxInt(u64), counter.frame);
}
