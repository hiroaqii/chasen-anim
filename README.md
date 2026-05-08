# chasen-anim

Small animation primitive package for [Chasen](https://github.com/hiroaqii/chasen)
terminal applications.

The Zig module name is `chasen_anim`.

`chasen-anim` is std-only. It does not depend on Chasen core, `chasen-ui`,
a renderer, or terminal state.

## Utilities

- `FrameCounter`: deterministic saturating frame counter.
- `progress(frame, max_frame)`: normalized `0.0...1.0` progress.
- `loopIndex(frame, len)`: wrap through fixed-length frame lists.
- `pingPongIndex(frame, len)`: bounce through fixed-length frame lists.

## Easing

- `ease.linear(t)`: constant-speed easing.
- `ease.inQuad(t)`: quadratic ease-in.
- `ease.outQuad(t)`: quadratic ease-out.
- `ease.inOutQuad(t)`: quadratic ease-in-out.

Easing functions clamp non-NaN inputs into `0.0...1.0`. `NaN` is not handled
specially and propagates.

## Transitions

- `TransitionKind`: built-in transition categories.
- `Transition`: retained transition state with `init`, `step`, `progress`,
  `done`, `remainingFrames`, `isZeroDuration`, and `setMaxFrame`.

Transition state does not draw, schedule timers, request frames, log, or trace.
Applications decide when to step, how to draw, and when to request another
frame.

## Transition Helpers

- `dissolve.threshold(seed, col, row)`: stable `0.0...1.0` threshold for one cell.
- `dissolve.isActive(seed, col, row, progress)`: whether one cell is active for
  the current progress.
- `sweep.columnThreshold(width, col, direction)`: stable `0.0...1.0` threshold
  for one column.
- `sweep.isColumnActive(width, col, progress, direction)`: whether one column is
  active for the current progress.

## Usage Pattern

`chasen-anim` computes animation state and numeric values. Applications or
higher-level packages decide how to render those values.

```zig
const anim = @import("chasen_anim");

var transition = anim.Transition.init(.fade, 30);

_ = transition.step();

const p = transition.progress();
const eased = anim.ease.outQuad(p);

if (!transition.done()) {
    // Request another frame from the app/runtime.
}
```

Apps can read query values such as `frame`, `max_frame`, `progress()`, `done()`,
and `remainingFrames()` and pass them to their own logger, trace hook, or debug
overlay.

## Examples

Example usage lives in examples:

- `examples/dissolve/main.zig`
- `examples/transition/main.zig`

Run examples from this repository:

```sh
zig build run-dissolve
zig build run-transition
```

Build all examples:

```sh
zig build check-examples
```

## Development

Run tests:

```sh
zig build test
```

Build individual examples:

```sh
zig build check-dissolve
zig build check-transition
```
