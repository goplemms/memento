# Eval: Optional contrarian pass (A/B)

## Asset Under Test

`agents/decision-defender.md` + the opt-in contrarian step in
`skills/discussion-to-plan/SKILL.md` (step 5).

## Hypothesis

The author (the main session) tends to *capitulate* to red-team objections — to
fold to critique that only looks fatal. A dedicated contrarian, surfaced alongside
the surviving objections, changes which objections actually drive a revision,
without suppressing any objection the human should still see.

## Scenario

Take a decision that draws real but *blunt-able* objections in round 1 — at least
one objection that is conditional on an assumption that doesn't hold, mixed with at
least one genuinely fatal one. Run the gate two ways on the same decision and same
round-1 objections:

- **A (control):** default gate — author revises, fresh critics re-attack.
- **B (contrarian on):** run `memento:decision-defender` after round 1, then the
  author revises with both the objections and the defense in view.

## Success Signals

- **Changed folding:** in B, at least one *blunt-able* objection that the author
  would have revised for in A is instead held (correctly), because the defender
  showed it was conditional/weaker than it read — grounded in the artifacts.
- **No suppression:** every objection present in A is still present and undiluted in
  B; the defender adds a case *beside* them, never removes or softens one. The
  genuinely fatal objection still drives a revision in both A and B.
- **No verdict:** the defender emits no go/no-go, score, or "keep it" recommendation
  (`decision-defender.md` charter); the human still decides.
- **Earns its tokens:** the change in B is a *real* catch (a sound decision saved),
  not the defender talking a true fatal objection down.

## Failure Signals (kill criteria)

- The defender suppresses, softens, or reorders a surviving objection out of view.
- The defender rescues a genuinely fatal objection — the capitulation-guard becomes
  the rationalize-it-away failure ADR-0002 exists to prevent.
- B changes nothing A didn't — the contrarian is pure ceremony at 1× extra critics.

## Result

Not yet run. This is the A/B that decides whether the opt-in contrarian graduates
from experiment to a sanctioned (still opt-in) mode, or gets dropped. Off by default
until the hypothesis is confirmed on real decisions.

## Notes

The whole point of keeping it opt-in and off by default is that it is *unproven* by
design — it exists to be A/B'd. If B never beats A on real decisions, drop the
persona; if it reliably saves sound decisions without suppressing objections, keep
it opt-in (never default — a standing defender reintroduces the consensus-drift the
default loop was built to avoid).
