---
name: orchestrate
description: Drive a feature from a fuzzy goal to a merged, durable result through a lean loop — brief the goal, converge on an MVP contract, build in user-testable milestones, graduate the durable record, archive, and GC. The kit's top-level workflow; composes discussion-to-plan, implement, and land. Use when starting or driving a feature end-to-end.
---

# Orchestrate

## Purpose

Drive a feature from a fuzzy goal to a merged, durable result through a lean
loop: brief the goal → back-and-forth to an MVP contract → build in
user-testable milestones → graduate the durable record → archive → GC. This is
the kit's top-level workflow; it composes `memento:discussion-to-plan`,
`memento:implement`, and `memento:land`.

## Inputs

- A feature goal (often fuzzy) and the repo it lives in
- The kit installed as a plugin (so `memento:orchestrate` resolves to this
  canonical file and `${CLAUDE_PLUGIN_ROOT}` points at the kit)
- A `scratchpad/` workspace (run `${CLAUDE_PLUGIN_ROOT}/bin/new-feature.sh` or
  `memento:workflow-init` first)

## Process

1. **Brief.** Restate the goal in one sentence as a hypothesis. Confirm the repo
   and the workspace dir.
2. **Contract.** Use `memento:discussion-to-plan` to converge on an MVP contract:
   north-star goal, non-scope, and ordered milestones. Write `plan.md`. Each
   milestone MUST carry an inline user-testable gate (web → page/button · CLI →
   command + output · lib → invokable runner).
3. **Open the ledger (opt-in).** For contested or multi-track work, scaffold
   `decisions.md`. Otherwise skip it — stay thin.
4. **Build a milestone.** Hand the active milestone to `memento:implement`. Keep
   `PROGRESS.md` current: status table, current block (milestone, last-green
   sha, next step, blockers).
5. **Commit gate.** A milestone is "in progress" until BOTH its tests are green
   AND its user-testable gate is met by the user. Only then commit. Never
   auto-commit; stage by name and pause for approval. After a commit that makes a
   *major* change (public API, storage layout, data model, config surface, or a
   workflow/convention the docs describe), fire a background doc-refresh agent so
   stale docs don't accrete — see "Doc refresh" below. Don't block the commit on it.
6. **Ledger courier.** When a decision is made mid-stream, carry it into
   `decisions.md`. Classify first and confirm with the user: a **pivot**
   supersedes the affected decision and re-opens it (and revises the Goal); an
   **adjustment** adds a new milestone (Goal untouched). Superseded entries are
   never deleted — they keep a "Superseded by" link.
7. **Iterate** milestones until the plan is satisfied.
8. **Land.** Hand off to `memento:land` for the merge ritual and reflection.
9. **Graduate → archive → sweep.** Decide where the durable record goes
   (graduation routing below; agent proposes, user confirms), fill `PROGRESS.md`
   Closeout, run `${CLAUDE_PLUGIN_ROOT}/bin/archive-feature.sh`, then
   `${CLAUDE_PLUGIN_ROOT}/bin/sweep-archive.sh` to GC old archives.

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
wrong or misleading given the change. Do not touch the scratchpad workspace, migration
files, or test files.

After editing, report a one-line summary of every file you changed and what you fixed.
```

## Outputs

- `plan.md` + `PROGRESS.md` (and optionally `decisions.md` / `agents.md`)
- A series of commits, each at a green + user-testable milestone
- A graduated durable record, an archived workspace, and a swept archive

## Notes

Mid-stream pivots and adjustments are normal — name them explicitly so the
record stays honest. The whole loop is markdown + three structure scripts; if
you reach for more tooling, stop and ask whether the friction is real yet.
