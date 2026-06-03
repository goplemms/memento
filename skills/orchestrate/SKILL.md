# Orchestrate

## Purpose

Drive a feature from a fuzzy goal to a merged, durable result through a lean
loop: brief the goal → back-and-forth to an MVP contract → build in
user-testable milestones → graduate the durable record → archive → GC. This is
the kit's top-level workflow; it composes `discussion-to-plan`, `implement`,
and `land`.

## Inputs

- A feature goal (often fuzzy) and the repo it lives in
- The kit installed (so `/orchestrate` resolves to this canonical file)
- A `scratchpad/` workspace (run `new-feature.sh` or `/workflow-init` first)

## Process

1. **Brief.** Restate the goal in one sentence as a hypothesis. Confirm the repo
   and the workspace dir.
2. **Contract.** Use `discussion-to-plan` to converge on an MVP contract:
   north-star goal, non-scope, and ordered milestones. Write `plan.md`. Each
   milestone MUST carry an inline user-testable gate (web → page/button · CLI →
   command + output · lib → invokable runner).
3. **Open the ledger (opt-in).** For contested or multi-track work, scaffold
   `decisions.md`. Otherwise skip it — stay thin.
4. **Build a milestone.** Hand the active milestone to `implement`. Keep
   `PROGRESS.md` current: status table, current block (milestone, last-green
   sha, next step, blockers).
5. **Commit gate.** A milestone is "in progress" until BOTH its tests are green
   AND its user-testable gate is met by the user. Only then commit. Never
   auto-commit; stage by name and pause for approval.
6. **Ledger courier.** When a decision is made mid-stream, carry it into
   `decisions.md`. Classify first and confirm with the user: a **pivot**
   supersedes the affected decision and re-opens it (and revises the Goal); an
   **adjustment** adds a new milestone (Goal untouched). Superseded entries are
   never deleted — they keep a "Superseded by" link.
7. **Iterate** milestones until the plan is satisfied.
8. **Land.** Hand off to `land` for the merge ritual and reflection.
9. **Graduate → archive → sweep.** Decide where the durable record goes
   (graduation routing below; agent proposes, user confirms), fill `PROGRESS.md`
   Closeout, run `archive-feature.sh`, then `sweep-archive.sh` to GC old archives.

## Graduation routing (judgment — propose, user confirms)

- **Commit body** — default home for most durable context.
- **Lasting design decision** → the repo's architecture/decision doc.
- **User-facing change** → README / guides.
- **Spike** → nothing; let it be archived.
- **Improved a workflow asset** → upstream to memento (see `/workflow-sync`).

Never build a master `FEATURES.md` index. No blocking commit hooks.

## Outputs

- `plan.md` + `PROGRESS.md` (and optionally `decisions.md` / `agents.md`)
- A series of commits, each at a green + user-testable milestone
- A graduated durable record, an archived workspace, and a swept archive

## Notes

Mid-stream pivots and adjustments are normal — name them explicitly so the
record stays honest. The whole loop is markdown + three structure scripts; if
you reach for more tooling, stop and ask whether the friction is real yet.
