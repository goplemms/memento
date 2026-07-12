# ADR-0002: Red-team decisions before they graduate

- **Status:** Proposed
- **Date:** 2026-07-12

## Context

In the plan flow, a decision moves from user-alignment straight into the plan
document with no stress test. A decision can read as sound in its own statement
and still be wrong against the real code, incentives, or scope — and the plan
then builds on it. Absent an adversarial check, those failures surface at
implementation, where they are far more expensive to unwind than at design
time. Observed in real use: independent, artifact-grounded critique reliably
surfaces concept-level failures that a single author or a generic self-review
rationalizes away — a choice that collapses against the actual code, a plan
that misrepresents its own goal, an apparently-"buildable" scope that is
actually empty because its novel parts secretly depend on deferred work.

## Decision

Add an adversarial-review gate to `discussion-to-plan`: before a substantive
decision (or a small batch) graduates into the plan, fan out a few independent
critics — each with a distinct lens and a mandate to break the decision,
grounding every claim in the real code/artifacts — keep the objections that
survive, and revise or confirm. A decision is **PROVISIONAL** until it clears
the gate and **CLEARED** after.

## Alternatives considered

- **A single self-review pass.** Cheapest, but tends to reproduce the author's
  blind spot; the value comes from independence and diverse lenses.
- **Review only at land/reflection time.** Too late — the plan, and often the
  build, already rest on the decision.
- **Red-team every decision, always.** Too costly; batching plus a
  "substantive, expensive-to-get-wrong only" guardrail keeps it worth its token
  cost.

## Consequences

- **Easier:** design errors are caught while they're cheap to change, not at
  build time; the plan carries an explicit PROVISIONAL → CLEARED trail.
- **Owed / harder:** the pass spends real tokens (mitigate by batching
  decisions and reserving it for consequential calls), and its value depends on
  the critics being genuinely independent and grounded in the actual artifacts
  — a generic, ungrounded "review" degrades it.
- **Revisit when:** the token cost outweighs the catch rate on smaller efforts,
  or a lighter heuristic proves as reliable.
