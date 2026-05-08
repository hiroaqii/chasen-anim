const progress_mod = @import("progress.zig");

/// Built-in transition categories supported by chasen-anim.
///
/// `TransitionKind` only names the transition shape. It does not store frame
/// progress, timing, or drawing state. Progress and timing belong to
/// `Transition`; renderer-specific drawing state belongs outside this module.
pub const TransitionKind = enum {
    /// No visual transition.
    none,

    /// Gradually reveal or hide content by normalized progress.
    fade,

    /// Temporarily replace parts of the output with noisy visual fragments.
    glitch,

    /// Reveal cells in a deterministic scattered order.
    dissolve,

    /// Reveal content along one direction over time.
    sweep,

    /// Reveal horizontal or vertical lines in sequence.
    lines,

    /// Reveal lines from opposing directions.
    lines_cross,
};

/// Retained state for one transition.
///
/// `Transition` tracks which transition is active, the current frame, and the
/// frame count that represents completion. It can advance by one frame, report
/// normalized progress, and report whether that progress has completed.
pub const Transition = struct {
    /// Transition shape to apply.
    kind: TransitionKind = .none,

    /// Current transition frame.
    ///
    /// Zero represents a transition that has not advanced yet.
    frame: u64 = 0,

    /// Frame count that represents completion.
    ///
    /// A value of zero is reserved for later behavior definition.
    max_frame: u64 = 0,

    /// Create a transition at frame zero.
    ///
    /// This only initializes retained state. It does not advance the transition
    /// or define completion behavior for `max_frame == 0`.
    pub fn init(kind: TransitionKind, max_frame: u64) Transition {
        return .{
            .kind = kind,
            .frame = 0,
            .max_frame = max_frame,
        };
    }

    /// Advance by one transition frame and return the new frame number.
    ///
    /// The increment is saturating. `step` does not stop at completion; callers
    /// can use `done()` to decide whether to request another frame.
    pub fn step(self: *Transition) u64 {
        self.frame +|= 1;
        return self.frame;
    }

    /// Return normalized transition progress in the range 0.0...1.0.
    ///
    /// This follows the shared `progress(frame, max_frame)` helper, including
    /// treating `max_frame == 0` as already complete.
    pub fn progress(self: Transition) f32 {
        return progress_mod.progress(self.frame, self.max_frame);
    }

    /// Return whether the transition has reached completion.
    ///
    /// This follows `progress()`: overrun frames and `max_frame == 0` are both
    /// treated as complete.
    pub fn done(self: Transition) bool {
        return self.progress() >= 1.0;
    }

    /// Return how many frames remain until completion.
    ///
    /// Completed, overrun, and zero-duration transitions return zero.
    pub fn remainingFrames(self: Transition) u64 {
        if (self.frame >= self.max_frame) return 0;
        return self.max_frame - self.frame;
    }
};

test "TransitionKind exposes initial transition categories" {
    const kinds = [_]TransitionKind{
        .none,
        .fade,
        .glitch,
        .dissolve,
        .sweep,
        .lines,
        .lines_cross,
    };

    try @import("std").testing.expectEqual(@as(usize, 7), kinds.len);
}

test "Transition defaults to no transition at frame zero" {
    const std = @import("std");
    const transition: Transition = .{};

    try std.testing.expectEqual(TransitionKind.none, transition.kind);
    try std.testing.expectEqual(@as(u64, 0), transition.frame);
    try std.testing.expectEqual(@as(u64, 0), transition.max_frame);
}

test "Transition stores explicit state" {
    const std = @import("std");
    const transition: Transition = .{
        .kind = .fade,
        .frame = 3,
        .max_frame = 12,
    };

    try std.testing.expectEqual(TransitionKind.fade, transition.kind);
    try std.testing.expectEqual(@as(u64, 3), transition.frame);
    try std.testing.expectEqual(@as(u64, 12), transition.max_frame);
}

test "Transition init starts at frame zero" {
    const std = @import("std");
    const transition = Transition.init(.sweep, 24);

    try std.testing.expectEqual(TransitionKind.sweep, transition.kind);
    try std.testing.expectEqual(@as(u64, 0), transition.frame);
    try std.testing.expectEqual(@as(u64, 24), transition.max_frame);
}

test "Transition step advances one frame" {
    const std = @import("std");
    var transition = Transition.init(.fade, 12);

    try std.testing.expectEqual(@as(u64, 1), transition.step());
    try std.testing.expectEqual(@as(u64, 1), transition.frame);
    try std.testing.expectEqual(@as(u64, 2), transition.step());
    try std.testing.expectEqual(@as(u64, 2), transition.frame);
}

test "Transition step saturates at u64 max" {
    const std = @import("std");
    var transition: Transition = .{
        .kind = .fade,
        .frame = std.math.maxInt(u64),
        .max_frame = std.math.maxInt(u64),
    };

    try std.testing.expectEqual(std.math.maxInt(u64), transition.step());
    try std.testing.expectEqual(std.math.maxInt(u64), transition.frame);
}

test "Transition progress returns normalized frame progress" {
    const std = @import("std");
    const transition: Transition = .{
        .kind = .fade,
        .frame = 6,
        .max_frame = 12,
    };

    try std.testing.expectEqual(@as(f32, 0.5), transition.progress());
}

test "Transition progress clamps completed and overrun frames" {
    const std = @import("std");
    try std.testing.expectEqual(@as(f32, 1.0), (Transition{
        .kind = .fade,
        .frame = 12,
        .max_frame = 12,
    }).progress());
    try std.testing.expectEqual(@as(f32, 1.0), (Transition{
        .kind = .fade,
        .frame = 13,
        .max_frame = 12,
    }).progress());
}

test "Transition progress treats zero max frame as complete" {
    const std = @import("std");
    const transition = Transition.init(.none, 0);

    try std.testing.expectEqual(@as(f32, 1.0), transition.progress());
}

test "Transition done is false before completion" {
    const std = @import("std");
    const transition: Transition = .{
        .kind = .fade,
        .frame = 6,
        .max_frame = 12,
    };

    try std.testing.expect(!transition.done());
}

test "Transition done is true at completion and after overrun" {
    const std = @import("std");
    try std.testing.expect((Transition{
        .kind = .fade,
        .frame = 12,
        .max_frame = 12,
    }).done());
    try std.testing.expect((Transition{
        .kind = .fade,
        .frame = 13,
        .max_frame = 12,
    }).done());
}

test "Transition done treats zero max frame as complete" {
    const std = @import("std");

    try std.testing.expect((Transition{}).done());
    try std.testing.expect(Transition.init(.fade, 0).done());
}

test "Transition remainingFrames returns frames until completion" {
    const std = @import("std");
    const transition: Transition = .{
        .kind = .fade,
        .frame = 6,
        .max_frame = 12,
    };

    try std.testing.expectEqual(@as(u64, 6), transition.remainingFrames());
}

test "Transition remainingFrames returns zero after completion and overrun" {
    const std = @import("std");
    try std.testing.expectEqual(@as(u64, 0), (Transition{
        .kind = .fade,
        .frame = 12,
        .max_frame = 12,
    }).remainingFrames());
    try std.testing.expectEqual(@as(u64, 0), (Transition{
        .kind = .fade,
        .frame = 13,
        .max_frame = 12,
    }).remainingFrames());
}

test "Transition remainingFrames treats zero max frame as zero remaining" {
    const std = @import("std");

    try std.testing.expectEqual(@as(u64, 0), (Transition{}).remainingFrames());
    try std.testing.expectEqual(@as(u64, 0), Transition.init(.fade, 0).remainingFrames());
}
