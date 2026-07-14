# Decisions (ADRs)

The durable record of decisions that shape memento — the *why*, not just the
*what*. Code shows what we did; these show what we chose, what we ruled out, and
what would make us reconsider, so a future reader (human or agent) doesn't
relitigate a settled question.

This replaces the old copy/paste "graduate the durable record" step: decisions
now land here, versioned and greppable, next to the code they justify.

## Convention

- One file per decision: `NNNN-kebab-title.md`, zero-padded, monotonic.
- Copy `templates/adr.md` to start.
- Status lifecycle: **Proposed → Accepted → (later) Superseded by ADR-XXXX**.
- Supersede, never delete or rewrite. A decision that aged badly is still a
  record — mark it superseded and link forward to the one that replaced it.

## Neutrality

An ADR lives in the repo it concerns. If a decision is upstreamed to memento
from another project, it must be **project-neutral**: generalize the claim,
drop project nouns, and keep the rich local context in that project's own ADR.
This mirrors the phone-home rule for skills — same trust boundary, same gate.

## Index

- [0001](0001-adopt-public-plugin-distribution.md) — Adopt public plugin
  distribution for the kit. *(Accepted)*
- [0002](0002-red-team-decisions-before-they-graduate.md) — Red-team decisions
  before they graduate. *(Proposed)*
