# The TL;DR Convention

## Why

Decision points bury the decision. A red-team readout, an audit's findings, a
commit gate, a backlog review — each arrives as a wall of correct, dense text,
and the one thing the reader actually has to do (choose) is somewhere inside it.
The volume is not the problem; the *ordering* is. This convention puts a fixed,
visually distinct, jargon-free summary where the reader hits it first.

One convention, two surfaces: an in-session **TL;DR block**, and the
PR-description lead in `memento:land`.

## The block

Always the same shape, so it can be recognized without being read — a rule, a
blockquote, a rule:

```text
---

> **TL;DR**
> - Cache keeps stale entries after a delete.
> - Fix is one file, no migration.
> - Your call: ship now or batch it?

---
```

## Rules

- **≤10 words a bullet, ≤5 bullets.** If it does not fit, the summary is doing
  the detail's job. (The red-team readout is exempt from the count — see below.)
- **No jargon, no file paths, no symbol names.** Those live below the fold. The
  detail is never omitted — only moved.
- **Nothing new.** Every bullet restates something the detail says. The TL;DR is
  a lens on the message, not a second source of truth.
- **Say what it costs and what you need.** A summary that only reports what
  happened does not help anyone decide. End on the ask when there is one.
- **Top when a decision is pending; bottom when it is a readout** of work just
  finished. The first is read-then-expand, the second is a recap.

## When it fires

At the named decision points:

| Skill | Moment |
|---|---|
| `discussion-to-plan` | the red-team readout, and the plan hand-off |
| `orchestrate` | the commit gate, before asking for approval |
| `implement` | handing a milestone back at its user-testable gate |
| `challenge` | what broke and what survived |
| `codebase-audit` | the findings report, ahead of triage |
| `decompose-to-issues` | the review-gate report |
| `land` | the PR description (the prose surface, below) |

...and **any time the user is being asked to choose** — a fork mid-flow counts
even when it is not a formal gate.

Do not fire it on ordinary short answers. The block earns its distinctiveness by
being rare; on every message it is just formatting.

## The one exception: the red-team readout

`discussion-to-plan`'s red-team readout departs from the rules above in two ways,
and only it does:

- **It keeps a grounding line** under each bullet — a `file:line` *or* a named
  condition, naming the mechanism in a clause. That readout is a verification
  record, and the grounding is its substance: an ungrounded objection is exactly
  what the gate exists to catch. Everywhere else, bullets stay bare.
- **It is not capped at 5 bullets.** Every surviving objection gets a line. The
  cap exists to stop a summary sprawling into the detail it sits above — but
  here the bullets *are* the findings, and dropping one to fit defeats the gate.
  A long readout is a signal about the decision, not a formatting problem.

The distinction generalizes: cap the block when the full detail sits directly
below it, and never when the block is the only place a finding appears.

## The PR surface

`memento:land` step 1 applies the same convention where the surface is prose
rather than a chat block: a ≤280-char plain-language lead saying what the change
gets the reader and whose work it eases, ~10-word bullets only where they earn
it, and the technical detail below its own heading. Worked before/after in
`examples/land.md`.

## The test

Could someone who has not read the detail say what is being decided and what it
costs them? If the bullets only parse for someone who already read below the
fold, they are at file-list altitude — raise them.
