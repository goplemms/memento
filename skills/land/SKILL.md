---
name: land
description: Close out a finished feature — merge the work, then run the reflection ritual that captures workflow-asset improvements while context is freshest, graduate the durable record, archive, and sweep. Use when a feature's milestones are all done and it's time to merge and reflect.
---

# Land

## Purpose

Close out a finished feature: merge the work, then run the reflection ritual
that captures workflow improvements at the exact moment they're freshest. This
is where workflow-asset learning gets crystallized so the NEXT feature is easier.

## Inputs

- A feature whose milestones are all `done` (green + gates met)
- The feature workspace (`plan.md`, `PROGRESS.md`)
- The kit installed as a plugin (so `${CLAUDE_PLUGIN_ROOT}` resolves and asset
  improvements can be upstreamed to memento)

## Process

1. **Final review.** Confirm every milestone is green and its user-testable gate
   was met. Stage by name and commit/merge per the repo's convention.
2. **Reflect.** Ask the two questions while context is fresh:
   - What rules/skills/personas HELPED this feature? What got in the way?
   - Is there a workflow we can crystallize to make the next change easier
     (prompting/planning)?
3. **Capture improvements.** If a workflow asset should change, make the edit in
   the memento clone (the plugin source at `${CLAUDE_PLUGIN_ROOT}`, or the
   symlinked file under a `--user` install) and commit it there — or open a PR
   against memento. Don't leave the improvement stranded in the consuming repo.
   If the repo carries a vendored/forked copy, hand off to
   `memento:workflow-sync` to upstream it (repo → memento).
4. **Sync check.** Run `memento:workflow-sync` to detect any drift (including
   project-scope skills that shadow the kit) and reconcile.
5. **Graduate.** Decide where the durable record lives (see `memento:orchestrate`
   graduation routing); propose, let the user confirm. Fill `PROGRESS.md`
   Closeout (Graduated to / Archived).
6. **Archive + sweep.** Run `${CLAUDE_PLUGIN_ROOT}/bin/archive-feature.sh <dir>`
   (refuses without a complete Closeout), then
   `${CLAUDE_PLUGIN_ROOT}/bin/sweep-archive.sh` to GC old archives.

## Outputs

- Merged feature
- A reflection note (what helped / didn't)
- Any improved workflow asset committed back to memento
- A completed Closeout, archived workspace, swept archive

## Notes

The reflection is the habit that keeps the kit alive. Doing it at land time —
not "someday" — is what turns one-off lessons into durable, shared workflow.
