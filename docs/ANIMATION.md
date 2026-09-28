# Animation API Guide

[Back to README](../README.md)

These helpers are exported by `@import("chasen_anim")`. They compute values
without drawing, scheduling frames, or depending on Chasen.

- [Utilities](#utilities)
- [Easing](#easing)
- [Transitions](#transitions)
- [Transition Helpers](#transition-helpers)

## Utilities

- `FrameCounter`: deterministic saturating frame counter.
- `progress(frame, max_frame)`: normalized `0.0...1.0` progress.
- `loopIndex(frame, len)`: wrap through fixed-length frame lists.
- `pingPongIndex(frame, len)`: bounce through fixed-length frame lists.

`FrameCounter` saturates rather than wrapping on overflow. `progress` clamps at
one and treats a zero maximum as complete. Index helpers return zero for an
empty list; callers must still avoid indexing an empty list.

## Easing

- `ease.clamp01(value)`: clamp a non-NaN value into `0.0...1.0`.
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

`TransitionKind` names are categories, not implementations of drawing effects.
`max_frame` is a frame count, not a duration in milliseconds. A zero-frame
transition is immediately complete; callers decide when to stop stepping.
`step()` continues beyond completion with saturating increments. `setMaxFrame()`
changes the completion frame without resetting the current frame.

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
- `stagger.itemProgress(progress, index, count, delay)`: local `0.0...1.0`
  progress for one staggered item.
- `stagger.isStarted(progress, index, count, delay)`: whether one staggered item
  has started.
- `blink.phase(frame, period)`: normalized `0.0...1.0` position inside one
  blink period.
- `blink.isOn(frame, period, duty)`: whether the blink is on for the current
  frame.
- `wave.phase(frame, period, index, offset)`: normalized `0.0...1.0` phase for
  one indexed item.
- `pulse.value(frame, period)`: repeating `0.0...1.0...0.0` value for one
  pulse cycle.
- `pulse.valueFromPhase(phase)`: triangle `0.0...1.0...0.0` value for one
  normalized phase.
- `typewriter.visibleCount(progress, total)`: number of visible items for
  typewriter-style reveals.
- `glitch.sample(seed, frame, col, row)`: deterministic `0.0...1.0` sample for
  one cell at one frame.
- `glitch.isActive(seed, frame, col, row, probability)`: whether one cell should
  glitch for the current probability.

The frame and period arguments are integer counters. Keep their units consistent
and choose when to advance them in the application. For `blink`, a zero period
returns phase zero and `isOn` returns false. Its duty fraction is clamped into
`0.0...1.0`; a NaN duty returns false.
