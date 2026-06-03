# Land

## Purpose

Close out a finished feature: merge the work, then run the reflection ritual
that captures workflow improvements at the exact moment they're freshest. This
is where workflow-asset learning gets crystallized so the NEXT feature is easier.

## Inputs

- A feature whose milestones are all `done` (green + gates met)
- The feature workspace (`plan.md`, `PROGRESS.md`)
- The kit installed (so edits to skills are edits to memento)

## Process

1. **Final review.** Confirm every milestone is green and its user-testable gate
   was met. Stage by name and commit/merge per the repo's convention.
2. **Reflect.** Ask the two questions while context is fresh:
   - What rules/skills/personas HELPED this feature? What got in the way?
   - Is there a workflow we can crystallize to make the next change easier
     (prompting/planning)?
3. **Capture improvements.** If a workflow asset should change:
   - Under `--user` install, the skill/template/persona file is a symlink into
     memento — editing it IS editing memento. Make the edit, then commit it in
     the memento clone. No backport.
   - If the repo carries a vendored/forked copy instead, hand off to
     `/workflow-sync` to upstream it (repo → memento).
4. **Sync check.** Run `/workflow-sync` to detect any drift (including
   project-scope skills that shadow the kit) and reconcile.
5. **Graduate.** Decide where the durable record lives (see `orchestrate`
   graduation routing); propose, let the user confirm. Fill `PROGRESS.md`
   Closeout (Graduated to / Archived).
6. **Archive + sweep.** Run `archive-feature.sh <dir>` (refuses without a
   complete Closeout), then `sweep-archive.sh` to GC old archives.

## Outputs

- Merged feature
- A reflection note (what helped / didn't)
- Any improved workflow asset committed back to memento
- A completed Closeout, archived workspace, swept archive

## Notes

The reflection is the habit that keeps the kit alive. Doing it at land time —
not "someday" — is what turns one-off lessons into durable, shared workflow.
