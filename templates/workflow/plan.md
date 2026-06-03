# Plan: <FEATURE_NAME>

## Goal (north star)

One sentence describing the durable outcome. Revise this ONLY on a real pivot,
never to track day-to-day progress.

## Non-scope

- What this feature explicitly will NOT do
- Adjacent work deliberately deferred

## Milestones

Each milestone is ordered, independently shippable, and carries an inline
USER-TESTABLE GATE. A milestone stays "in progress" until tests are green AND
the gate is met.

### M1 — <short name>

- What changes
- **User-testable gate:** <web → page/button to click · CLI → command + expected
  output · lib → invokable runner/test to call>

### M2 — <short name>

- What changes
- **User-testable gate:** <...>

## Notes

- Pivot = revise Goal + supersede affected decisions (see decisions.md).
- Adjustment = add a new milestone, leave Goal untouched.
