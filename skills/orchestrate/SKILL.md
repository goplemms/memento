---
name: orchestrate
description: Drive a feature from a fuzzy goal to a merged, durable result through a lean loop — brief the goal, converge on an MVP contract, build in user-testable milestones, graduate the durable record, archive, and GC. The kit's top-level workflow; composes discussion-to-plan, implement, and land. Use when starting or driving a feature end-to-end.
when_to_use: Driving a feature start to finish; the user asks to plan and build something end-to-end, or to run the full memento loop.
---

# Orchestrate

## Purpose

Drive a feature from a fuzzy goal to a merged, durable result through a lean
loop: brief the goal → back-and-forth to an MVP contract → build in
user-testable milestones → graduate the durable record → archive → GC. This is
the kit's top-level workflow; it composes `memento:discussion-to-plan`,
`memento:implement`, and `memento:land`, and leans on `memento:ship`,
`memento:handoff-prompt`, and `memento:domain-decisions` along the way.

## Inputs

- A feature goal (often fuzzy) and the repo it lives in
- The kit installed as a plugin (so `memento:orchestrate` resolves to this
  canonical file and `${CLAUDE_PLUGIN_ROOT}` points at the kit)
- A feature workspace (run `${CLAUDE_PLUGIN_ROOT}/bin/new-feature.sh` or
  `memento:workflow-init` first). `${CLAUDE_PLUGIN_ROOT}/bin/workspace-root.sh`
  prints where workspaces live: the shared project folder in a Claude Projects
  thread, so the next thread can pick the feature up, else `scratchpad/`

## Process

1. **Brief.** Restate the goal in one sentence as a hypothesis. Confirm the repo
   and the workspace dir. If a workspace for this feature already exists under
   `workspace-root.sh`'s answer, resume from its `PROGRESS.md` instead of
   starting over.
2. **Contract.** Use `memento:discussion-to-plan` to converge on an MVP contract:
   north-star goal, non-scope, and ordered milestones. Write `plan.md`. Each
   milestone MUST carry an inline user-testable gate (web → page/button · CLI →
   command + output · lib → invokable runner).
3. **Open the ledger (opt-in).** For contested or multi-track work, scaffold
   `decisions.md`. Otherwise skip it — stay thin.
4. **Build a milestone.** Hand the active milestone to `memento:implement`. Keep
   `PROGRESS.md` current: status table, current block (milestone, last-green
   sha, next step, blockers). **Delegate by default:** the main session plans,
   decides, and reviews, and subagents do the reading and the edits, in
   parallel where the work splits cleanly. Give each subagent a
   self-contained brief (the shape `memento:handoff-prompt` writes), make
   research and audit subagents read-only, and pick a cheaper model for
   mechanical work. Between milestones, check that each running subagent is
   still on its brief before trusting its output.
5. **Commit gate.** A milestone is "in progress" until BOTH its tests are green
   AND its user-testable gate is met by the user. Before committing a milestone
   that changed real behavior, run `memento:challenge` on the implementation **as
   a default step, not just on demand** — try to break it (missed cases, other
   code paths, namespace/edge assumptions the green tests never exercised) and
   trust it only when you can't; fold what survives back in *before* the gate.
   Trivial or purely mechanical changes (docs, config, a rename with green tests)
   may skip it — say so rather than skipping silently. Record the challenge in
   the milestone's **Review ledger** row in `PROGRESS.md`, next to implement's
   code-and-tests review (or `skipped: <why>`). `hooks/review-gate.sh` refuses
   `git commit` while an in-progress or testable milestone has no row, so the
   review can't quietly drop out late in a long session. Only then commit. Never
   auto-commit; stage by name and pause for approval — and **lead that pause with
   a TL;DR block** (see "Decision-point summaries" below) so the user can decide
   without reading the whole gate. After a commit that makes a
   *major* change (public API, storage layout, data model, config surface, or a
   workflow/convention the docs describe), fire a background doc-refresh agent so
   stale docs don't accrete — see "Doc refresh" below. Don't block the commit on it.
6. **Ledger courier.** When a decision is made mid-stream, carry it into
   `decisions.md`. Classify first and confirm with the user: a **pivot**
   supersedes the affected decision and re-opens it (and revises the Goal); an
   **adjustment** adds a new milestone (Goal untouched). Superseded entries are
   never deleted — they keep a "Superseded by" link. When the decision is a
   domain judgment rather than an engineering one (an accounting treatment, a
   business rule), don't make it: put it to the user through
   `memento:domain-decisions`.
7. **Iterate** milestones until the plan is satisfied. When a session has to
   stop with milestones left (context is full, the user is done for now, or the
   next step needs different access), write the pickup with
   `memento:handoff-prompt` instead of leaving the state in chat.
8. **Land.** Hand off to `memento:land` for the merge ritual and reflection.
   It uses `memento:ship` for the PR, CI, and merge.
9. **Graduate → archive → sweep.** Decide where the durable record goes
   (graduation routing below; agent proposes, user confirms), fill `PROGRESS.md`
   Closeout, run `${CLAUDE_PLUGIN_ROOT}/bin/archive-feature.sh`, then
   `${CLAUDE_PLUGIN_ROOT}/bin/sweep-archive.sh` to GC old archives.

## Decision-point summaries

Every moment this loop hands the user something to decide, open with the TL;DR
block from `${CLAUDE_PLUGIN_ROOT}/docs/tldr-convention.md`: a rule, a
blockquote headed **TL;DR**, and a rule — ≤5 bullets, ≤10 words each, no jargon,
file paths, or symbol names, ending on the call you need. The detail is never
omitted; it moves below the block.

That means the commit gate, a pivot/adjustment classification, graduation
routing, and **any other point where the user is asked to choose** — a fork
mid-flow counts even when it is not a formal gate. It does not mean every
message: the block only stays scannable while it stays rare.

In a Claude Projects thread that offers a decision card, put the call itself on
the card (for the commit gate: commit, revise, or hold, with commit
recommended only when tests are green and the challenge survived) and keep the
TL;DR block leading the reply. Never auto-commit on the card's recommendation;
a commit still waits for the user's tap or word.

## Graduation routing (judgment — propose, user confirms)

- **Commit body** — default home for most durable context.
- **Lasting design decision** → the repo's architecture/decision doc.
- **User-facing change** → README / guides.
- **Spike** → nothing; let it be archived.
- **Improved a workflow asset** → upstream to memento (see `memento:workflow-sync`).

Never build a master `FEATURES.md` index. No blocking commit hooks.

## Doc refresh (major changes only)

When a commit makes a major change, spawn a background general-purpose agent to
fix docs the change just made stale. Fire and move on — never block the commit.
Skip it for routine changes; this is only for shifts that ripple into the docs.

```
You are a documentation updater for this repository.

A code change was just made: <SUMMARY of what changed and why>

Search the docs (all .md files) and source docstrings/comments for any text that now
conflicts with or is made stale by this change. For each stale passage, edit it in place to
reflect current truth. Do NOT rewrite healthy docs — only fix passages that are factually
wrong or misleading given the change. This includes **derived docs that render from
code-fenced sources** — Mermaid diagrams, architecture diagrams, systems atlases, data-flow
maps: check the diagram itself still matches reality, not just the prose around it (a stale
diagram rarely reads as plainly-wrong text). Do not touch the feature workspace, migration
files, or test files.

After editing, report a one-line summary of every file you changed and what you fixed.
```

## Outputs

- `plan.md` + `PROGRESS.md` (and optionally `decisions.md` / `agents.md`)
- A series of commits, each at a green + user-testable milestone
- A graduated durable record, an archived workspace, and a swept archive

## Notes

**Plan then challenge is the spine of the loop.** Converge on the contract, then
before each real commit try to break what you built — an implementation that was
only ever walked forward tends to ship incomplete (the case it doesn't handle is
exactly the one you didn't think to try). The commit gate's default challenge
step is where that happens; treat it as part of "done," not an optional extra.
And when a milestone's plan was *derived* rather than discussed — an audit's
fix-list, a migration inventory — challenge the **plan itself before the first
edit** too: a pre-mortem there is strictly cheaper than one at the commit gate,
and it is where a confidently-wrong fix (one that would break a deliberate
behavior the derivation missed) gets caught with zero code written.

Mid-stream pivots and adjustments are normal — name them explicitly so the
record stays honest. The whole loop is markdown + three structure scripts; if
you reach for more tooling, stop and ask whether the friction is real yet.
