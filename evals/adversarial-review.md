# Eval: Adversarial Review gate

## Asset Under Test

`skills/discussion-to-plan/SKILL.md` (the step-5 red-team-before-graduate gate)

## Scenario

Drive a design-heavy planning session that settles a sequence of consequential
decisions, and run the adversarial-review gate on each (or on a small batch)
before it graduates into the plan.

## Success Signals

- surfaces concept-level failures the decision's own statement hides, grounded
  in the real code/artifacts
- independent, distinct-lens critics catch what a single review pass misses
- decisions carry a PROVISIONAL → CLEARED trail; weak ones get revised, not shipped

## Result

Pass. Across a multi-decision planning session, the gate repeatedly caught
choices that read as sound but collapsed against the actual code and scope — a
dominated trade-off that taught the opposite of its intent, a plan that
misrepresented its own goal, and a "buildable" scope whose novel parts secretly
depended on deferred work — before any of them reached the plan.

## Notes

Cost is real (several critics per pass), so it pays to batch decisions and
reserve the gate for consequential calls. Independence and grounding in the
actual artifacts are what make it work; a generic self-review reproduces the
blind spot.
