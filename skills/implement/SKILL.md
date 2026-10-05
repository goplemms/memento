---
name: implement
description: Execute a single milestone from plan.md to the point where its tests are green and its user-testable gate can be demonstrated. Scoped to one milestone at a time; hands back to orchestrate for the commit gate. Use when building the active milestone of a kit-driven feature.
when_to_use: Executing one milestone from plan.md; the user asks to build or implement the next planned slice until it's green and demonstrable.
---

# Implement

## Purpose

Execute a single milestone from `plan.md` to the point where its tests are green
and its user-testable gate can be demonstrated. Scoped, one milestone at a time.

## Inputs

- The active milestone from `plan.md` (including its user-testable gate)
- `PROGRESS.md` current block (last-green sha, next step, blockers)
- Optional `agents.md` if the milestone is split across subagents

## Process

1. Read the active milestone and its user-testable gate. Restate what "done"
   means for THIS milestone in one sentence.
2. If using subagents, write/refresh `agents.md` for the current milestone only:
   each agent's concern, files, do-not-touch, exit criteria.
3. Make the smallest change that moves the milestone forward. Prefer one working
   slice over a broad scaffold.
4. Run the tests. Keep going until they are green.
5. **Review the code and the tests.** Don't skip this step: your own pass
   shares your blind spots, and when these reviews ran in past sessions they
   kept finding real bugs in Claude's own work. On the milestone's diff:
   - Run `/simplify` for reuse, simplification and altitude.
   - Spawn one read-only reviewer subagent (opus when available) with the
     diff, the milestone's "done" sentence, and this brief: *find defects, do
     not fix them; for each, give file:line, the failing input, and how sure
     you are. Then judge the tests: would they fail on a deliberately wrong
     version of this change? Name the wrong version they would miss.*
   - Re-run each finding yourself before acting on it. Fix what holds up, add
     the missing test for any wrong version the suite would let through, and
     get back to green.
   - Add the milestone's row to `PROGRESS.md`'s **Review ledger**: what
     reviewed it, what it found, and what was folded in. For a purely
     mechanical change (docs, config, a rename with green tests), write
     `skipped: <why>` instead. `hooks/review-gate.sh` stops the commit until
     the row exists.
6. Demonstrate the user-testable gate (run the command, point at the page,
   invoke the runner) so the user can confirm it.
7. Update `PROGRESS.md`: move the milestone `in-progress` → `testable`, record
   the last-green sha and the next step.
8. Hand back to `memento:orchestrate` for the commit gate. Do not commit here.
   Open the hand-off with a TL;DR block — ≤5 bullets, ≤10 words each, no jargon,
   paths, or symbol names: what the milestone now does, what it cost, and what
   the user should try. See `${CLAUDE_PLUGIN_ROOT}/docs/tldr-convention.md`.

## Outputs

- A milestone whose tests pass and whose gate is demonstrable
- An updated `PROGRESS.md` current block, and a Review ledger row for the milestone
- (If used) an `agents.md` scoped to the milestone just worked

## Notes

Stay inside the milestone. If you discover the plan is wrong, surface it as a
pivot/adjustment to `memento:orchestrate` rather than silently widening scope.
