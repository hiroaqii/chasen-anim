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
/// frame count that represents completion. It does not advance itself yet;
/// stepping and progress helpers are added separately so state shape can be
/// reviewed on its own.
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
