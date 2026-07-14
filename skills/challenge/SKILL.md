---
name: challenge
description: Adversarially pressure-test the plan, implementation, or theory the session is currently working through — before committing to it. State what it claims, construct the cases or scenarios that would break it, and actually run them instead of re-walking the happy path. Trust it only once you've genuinely tried to break it and couldn't. Use when about to commit to an approach, ship an implementation, or accept an explanation — especially when it looks right.
---

# Challenge

## Purpose

Pressure-test the current thinking before committing to it. A plan, an implementation,
or a theory that merely *looks* right — or that you've only ever walked forward through —
hasn't earned commitment. Try to break it; trust it only when you can't.

## Inputs

- the plan / implementation / theory currently under consideration
- what it claims to achieve, produce, or explain
- the context it has to hold in

## Process

1. State it in one line: what does it claim, promise, or assume?
2. Enumerate the ways it could be wrong — failure modes, missed cases, counterexamples,
   false assumptions. Ask "what would have to be true for this to fail?" not just "why
   will it work?"
3. Actually run it against those: trace the plan through the failure scenario, feed the
   implementation the breaking input, seek the observation that would falsify the theory.
   Re-walking the happy path proves little — it only confirms what you already believe.
4. Surface the load-bearing assumptions — the things that must hold for it to work but
   that you haven't checked. An unverified assumption is where it breaks.
5. Diagnose right-for-the-wrong-reason: it "works" or "holds" by coincidence, or because
   an unstated condition happens to be true, or only in the order/context you tried — not
   because of the mechanism you're claiming.
6. Revise to address what broke, then re-challenge. Iterate until it survives a genuine
   attempt to break it — or discard it if it can't.
7. If the challenge is cheap to re-run (a check, a scenario, a script), keep it so the
   same failure can't quietly return.

## Outputs

- the ways it could fail, *tested* — which broke it, which it survived
- the load-bearing assumptions, flagged verified vs unverified
- the revised plan / implementation / theory, re-challenged
- optionally, a preserved check for the failure modes worth guarding against

## Notes

- The failure this prevents: committing to something that only ever got the happy-path
  walk-through — a plan with an unhandled case, an implementation that's green for the
  wrong reason, a theory no evidence could have contradicted.
- Falsification over confirmation: a claim you can't imagine failing is one you haven't
  understood yet. Try to make it lie, and trust it only when you can't.
- "Looks stronger" is not "is stronger." The more elaborate option can be the more
  fragile one — only running the break-cases tells them apart, not your intuition about
  which looks robust.
- Cheapest to skip, most expensive to have skipped. The payoff peaks right *before* you
  commit — challenge it then, not after it has waved something through.
- It takes the shape of the thing under challenge: for a **plan** it's a pre-mortem (walk
  the scenario where it failed and ask why); for an **implementation** it's the breaking
  input / mutation (would it catch a deliberately wrong version?); for a **theory** it's
  the falsifying observation; for a **suite of checks** it's the specificity matrix — does
  each check fire on exactly its own case, or wave others through?
