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
5. Demonstrate the user-testable gate (run the command, point at the page,
   invoke the runner) so the user can confirm it.
6. Update `PROGRESS.md`: move the milestone `in-progress` → `testable`, record
   the last-green sha and the next step.
7. Hand back to `orchestrate` for the commit gate. Do not commit here.

## Outputs

- A milestone whose tests pass and whose gate is demonstrable
- An updated `PROGRESS.md` current block
- (If used) an `agents.md` scoped to the milestone just worked

## Notes

Stay inside the milestone. If you discover the plan is wrong, surface it as a
pivot/adjustment to `orchestrate` rather than silently widening scope.
