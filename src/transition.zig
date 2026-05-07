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
