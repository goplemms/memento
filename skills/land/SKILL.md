# Land

## Purpose

Close out a finished feature: merge the work, then run the reflection ritual
that captures workflow improvements at the exact moment they're freshest. This
is where workflow-asset learning gets crystallized so the NEXT feature is easier.

## Inputs

- A feature whose milestones are all `done` (green + gates met)
- The feature workspace (`plan.md`, `PROGRESS.md`)
- The kit installed (under a symlink install, edits to skills are edits to
  memento; under a plugin install, improvements upstream as a phone-home PR)

## Process

1. **Final review.** Confirm every milestone is green and its user-testable gate
   was met. Stage by name and commit/merge per the repo's convention.
2. **Reflect.** Ask the two questions while context is fresh:
   - What rules/skills/personas HELPED this feature? What got in the way?
   - Is there a workflow we can crystallize to make the next change easier
     (prompting/planning)?
3. **Capture improvements.** If a workflow asset should change, upstream by the
   path that matches how the kit is installed:
   - **Symlink (`--user`) install** — the skill/template/persona/agent file is a
     symlink into memento; editing it IS editing memento. Make the edit, then
     commit it in the memento clone. No backport.
   - **Plugin / cloud install** — there is no local clone or symlink. Open a
     phone-home PR against memento via the GitHub API, kept project-neutral
     (generalize-or-reject, category-only provenance, scan the diff *and* PR
     text) and left for human approval. See ADR-0001.
   - **Vendored/forked copy** — hand off to the `workflow-sync` skill to
     reconcile (repo → memento).
4. **Sync check.** Run the `workflow-sync` skill to detect any drift (including
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
