# chasen-anim

Small animation primitive package for [Chasen](https://github.com/hiroaqii/chasen)
terminal applications.

The Zig module name is `chasen_anim`.

`chasen-anim` is std-only. It does not depend on Chasen core, `chasen-ui`,
a renderer, or terminal state.

## Requirements

Zig 0.16.0.

## Current Status

Experimental; the API may change. The package provides deterministic values and
transition state, not a scheduler or ready-made visual effects.

## How It Fits With Chasen

The application owns time and frame scheduling. `chasen-anim` turns a frame or
phase into values; a renderer or a package such as
[chasen-graphics](https://github.com/hiroaqii/chasen-graphics) turns those values
into output. Chasen is not required to use this package.

## Usage

`chasen-anim` computes animation state and numeric values. Applications or
higher-level packages decide how to render those values.

```zig
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
```

Apps can read query values such as `frame`, `max_frame`, `progress()`, `done()`,
and `remainingFrames()` and pass them to their own logger, trace hook, or debug
overlay.

## API Guide

See the [Animation API Guide](docs/ANIMATION.md) for available helpers and their
behavior:

- [Frame counters, progress, and frame indices](docs/ANIMATION.md#utilities)
- [Easing](docs/ANIMATION.md#easing)
- [Transition state](docs/ANIMATION.md#transitions)
- [Dissolve, sweep, stagger, blink, wave, pulse, typewriter, and glitch](docs/ANIMATION.md#transition-helpers)

## Examples

These examples print animation values; they do not start a terminal UI:

- [transition](examples/transition/main.zig)
- [dissolve](examples/dissolve/main.zig)
- [sweep](examples/sweep/main.zig)
- [blink](examples/blink/main.zig)
- [wave](examples/wave/main.zig)

Run examples from this repository:

```sh
zig build run-transition
zig build run-dissolve
zig build run-sweep
zig build run-blink
zig build run-wave
```

## Development

Run tests and build all five examples from a repository checkout:

```sh
zig build test check-examples --summary all
```

Run tests alone with `zig build test`. Build an individual example with
`zig build check-<name>`, such as `zig build check-transition`.
No external package dependencies or sibling checkouts are required.

## License

See [LICENSE](LICENSE).
