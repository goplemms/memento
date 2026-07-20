---
name: codebase-audit
description: Audit a codebase along one chosen lens — data-access/consistency, orphaned or dead code, docs gone stale vs the code, duplicated logic ripe for reuse, security — with a read-only agent (or fan-out), returning severity-ranked findings (file:line, symptom, fix direction) and a single systemic root-fix recommendation. Use when you suspect a class of problem spans the codebase, or before a refactor, to map its real extent before touching anything.
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

## Process

1. **Frame the lens in one line.** What class of problem, and what would a single
   instance look like in code? If a symptom triggered this, state it and the
   assumption it violated — that assumption is usually the pattern.
2. **Dispatch a read-only audit agent.** Use a `general-purpose` subagent (run in
   the background; fan out one agent per lens for a broad sweep). Give it the
   lens, the known symptom, the invariants, and the output contract below — and
   tell it explicitly to **modify nothing**.
3. **Demand a severity-ranked report, not a wall of matches.** For each finding:
   `Critical / High / Medium / Low`, a one-line title, `file:line` + the actual
   snippet, which assumption or store it wrongly trusts, the concrete
   user-visible symptom, and a one-line fix direction.
4. **Require a systemic recommendation.** Is there a single root fix that
   collapses a cluster of findings, and which invariants constrain it? A good
   audit ends with "fix X and these five findings go away," not five unrelated
   patches.
5. **Verify before trusting.** Spot-check the highest-severity findings against
   the real code — audits hallucinate line numbers and over-claim. Drop what
   doesn't hold; keep what does with its evidence.
6. **Triage with the user.** Fix now / file as follow-up / won't-fix is their
   call. Feed the confirmed root fix into `memento:orchestrate` (or a single
   change); record the rest as follow-ups so they survive the session.

## Outputs

- A severity-ranked findings report (Critical→Low), each with file:line, the
  wrong assumption, the user-visible symptom, and a fix direction.
- A systemic "one root fix" recommendation with the invariants that constrain it.
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
