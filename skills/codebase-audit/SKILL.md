---
name: codebase-audit
description: Audit a codebase along one chosen lens — data-access/consistency, orphaned or dead code, docs gone stale vs the code, duplicated logic ripe for reuse, convention/terminology drift, security — with a read-only agent (or fan-out), returning impact-ranked findings (file:line, symptom, fix direction) and a single systemic root-fix recommendation. Use when you suspect a class of problem spans the codebase, or before a refactor, to map its real extent before touching anything.
---

<!--
Save as skills/codebase-audit/SKILL.md so the plugin loads it namespaced
(memento:codebase-audit). Read-only by design: it maps the problem; it does not
edit. Fixes go back through the normal loop and its commit gate.
-->

# Codebase Audit

## Purpose

Map the true extent of a *class* of problem across a codebase before acting on
it — so the fix addresses the systemic root, not the one symptom you happened to
hit. The deliverable is a triage-ready report, not edits.

## Inputs

- A **lens**: the class of issue to hunt. Pick one — e.g. data-access /
  consistency across two stores, path/id namespace mismatches, orphaned or
  never-cleaned rows, dead code, docs made stale by the code, duplicated logic
  that should share a helper, security.
- One concrete **symptom** if you have it (the bug that prompted the audit). It
  anchors the hunt and reveals the pattern to generalize from.
- Any **invariants** the eventual fix must respect (architecture decisions, ADRs,
  storage/layout guarantees).
- The repo's **existing canon** — its decision log, conventions doc, prior
  refactor campaigns — as the baseline. Findings are then framed as *drift from*
  that canon, and fixes *extend* it instead of minting a parallel one. (A useful
  first question: where did prior canon hold, and where did it drift? Canon tends
  to hold exactly where a guard enforces it and drift exactly where none reaches.)

## Process

1. **Frame the lens in one line.** What class of problem, and what would a single
   instance look like in code? If a symptom triggered this, state it and the
   assumption it violated — that assumption is usually the pattern.
2. **Dispatch a read-only audit agent.** Use a `general-purpose` subagent (run in
   the background; fan out one agent per lens for a broad sweep). Give it the
   lens, the known symptom, the invariants, and the output contract below — and
   tell it explicitly to **modify nothing**.
3. **Demand an impact-ranked report, not a wall of matches.** For each finding:
   a rank, a one-line title, `file:line` + the actual snippet, which assumption
   or store it wrongly trusts, the concrete user-visible symptom, and a one-line
   fix direction. Pick the ranking scale per lens — `Critical → Low` severity for
   correctness lenses; something like *confusion-caused ÷ rename-blast-radius*
   for a terminology lens. Treat comments and docs as **claims to verify**, not
   evidence — an audit's best finding is often a doc confidently describing
   behavior that doesn't exist.
4. **Require a systemic recommendation — with its tripwire.** Is there a single
   root fix that collapses a cluster of findings, and which invariants constrain
   it? A good audit ends with "fix X and these five findings go away," not five
   unrelated patches. And for each systemic fix, name the **guard that makes
   recurrence fail by name** (a grep-guard, a contract-walk test, a value pin, a
   visual e2e for a render surface) — without one, the class regrows behind you.
5. **Verify before trusting.** Spot-check the highest-impact findings against
   the real code — audits hallucinate line numbers and over-claim (and sometimes
   under-claim: a brief's own example may already be fixed). Drop what doesn't
   hold; keep what does with its evidence.
6. **Challenge the fix-list before the first edit.** Run `memento:challenge` on
   the *plan* the audit produced, not just later on the implementation — a
   pre-mortem here is strictly cheaper (nothing is built yet). This is where a
   confidently-wrong fix gets caught: a "make it throw" that would break a
   deliberate idempotency, a missing real-scene guard, a proposed artifact that
   is itself a drift surface.
7. **Triage with the user.** Fix now / file as follow-up / won't-fix is their
   call. Feed the confirmed root fix into `memento:orchestrate` (or a single
   change); record the rest as follow-ups so they survive the session. When the
   work splits into waves, sequence **correctness + tripwires first** — every
   later wave then runs under the protection the first wave built.

## Outputs

- An impact-ranked findings report, each with file:line, the wrong assumption,
  the user-visible symptom, and a fix direction.
- A systemic "one root fix" recommendation with the invariants that constrain it
  **and the tripwire that keeps it fixed**.
- A triage decision per finding, with follow-ups written down so nothing is lost.

## Notes

- **Read-only.** The audit maps; it does not edit. Every fix goes through the
  normal loop — including its commit gate and `memento:challenge`.
- **Scope the lens narrow enough to be answerable.** "Audit everything" returns
  mush; "where do we read store A but the data lives in store B" returns a
  punch-list.
- **Pairs with `memento:challenge`.** The audit finds the *class*; challenge then
  pressure-tests each fix so it covers the whole class, not just the first path
  (the fix that only closes the sink you looked at is the audit's failure mode in
  miniature).
- **The systemic recommendation is the payoff.** Ranked symptoms with no
  root-cause synthesis is a linter, not an audit.
- **When the outcome is codified conventions, point at living exemplars.** Cite
  real, shipped, guard-covered code as the thing to copy — never a synthetic
  "model file": nothing executes it, so it is a new drift surface the moment it
  lands (the same reason docs made a poor guard in the first place).
