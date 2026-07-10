# Eval: Curious Builder

## Asset Under Test

`agents/curious-builder.md`

## Scenario

Ask Claude Code to review the thin tooling library and recommend what to improve next.

## Success Signals

- it stays calm and iterative
- it avoids broad redesign ideas
- it gives one concrete next step instead of many options

## Result

Pass.

## Notes

The persona direction was good, but it needed one sharper operational rule. It now explicitly defaults to a single next step unless the user asks for alternatives.
