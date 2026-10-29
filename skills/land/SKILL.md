---
name: land
description: Close out a finished feature — merge the work, then run the reflection ritual that captures workflow-asset improvements while context is freshest, graduate the durable record, archive, and sweep. Use when a feature's milestones are all done and it's time to merge and reflect.
when_to_use: A feature is finished (all milestones green and gates met) and needs merging, reflection, graduation, and archival; capturing kit improvements at the end of a feature.
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

1. **Final review, then ship.** Confirm every milestone is green, its
   user-testable gate was met, and `PROGRESS.md`'s Queue is empty. Then hand the merge to `memento:ship`: commit by
   name, open the PR, watch CI to green, and merge on the user's word. **The PR
   description leads with a tweet-length (≤280 char), plain-language summary of
   what the change *gets* the reader and whose work it eases — altitude above
   the file list, no jargon.** Add ~10-word bullets only where they earn it;
   push the technical detail below the fold. This is the prose surface of the
   kit's TL;DR convention (`${CLAUDE_PLUGIN_ROOT}/docs/tldr-convention.md`);
   worked before/after in `examples/land.md`.
2. **Reflect.** `memento:ship` already asked the short version after the merge.
   Build on its answer rather than asking again. Also read the feature's Review
   ledger (which reviews found real defects, which were skipped, and why) and
   its Kit gaps: each is a proposed instruction fix for step 3, made where that
   instruction lives (a kit asset in memento, a repo's CLAUDE.md in that repo),
   or dropped with a reason if the user disagrees. One that won't be fixed in
   this feature goes to the ideas ledger in step 4. Then
   ask the two questions while context is fresh:
   - What rules/skills/personas HELPED this feature? What got in the way?
   - Is there a workflow we can crystallize to make the next change easier
     (prompting/planning)?
3. **Capture improvements.** If a workflow asset should change, make the edit in
   the memento clone (the plugin source at `${CLAUDE_PLUGIN_ROOT}`, or the
   symlinked file under a `--user` install) and commit it there — or open a PR
   against memento. Don't leave the improvement stranded in the consuming repo.
   If the repo carries a vendored/forked copy, hand off to
   `memento:workflow-sync` to upstream it (repo → memento).
4. **Route to the ideas ledger.** Run `${CLAUDE_PLUGIN_ROOT}/bin/ideas-ledger.sh`
   for the ledger's path. Every Kit gap, review finding or reflection
   follow-up that this feature did not fix becomes an `open` row, with this
   feature as its Source; nothing is left only in the archive. Then mark the
   feature's own row (add one if it has none) `shipped: <PR>`, and fill its
   **Did it fire?** cell with `look for: <what a real session would show if the
   change works> · unchecked`, concrete enough that the weekly pulse can spot
   it in a transcript or a workspace. Write the row IDs into Closeout's
   **Ledger** line. Write `none: <why>` there only when there are no
   leftovers and nothing a session could show (a spike, a docs typo);
   `archive-feature.sh` refuses a missing, placeholder or reasonless value.
5. **Sync check.** Run `memento:workflow-sync` to detect any drift (including
   project-scope skills that shadow the kit) and reconcile.
6. **Graduate.** Decide where the durable record lives (see `memento:orchestrate`
   graduation routing); propose, let the user confirm (on a decision card when
   the session offers one). Fill `PROGRESS.md`
   Closeout (Graduated to / Ledger / Archived).
7. **Archive + sweep.** Run `${CLAUDE_PLUGIN_ROOT}/bin/archive-feature.sh <dir>`
   (refuses without a complete Closeout; it archives within the same workspace
   root, so a shared-folder feature stays in the shared folder), then
   `${CLAUDE_PLUGIN_ROOT}/bin/sweep-archive.sh` to GC old archives.

## Outputs

- Merged feature
- A reflection note (what helped / didn't)
- Any improved workflow asset committed back to memento
- Ideas-ledger rows: leftovers as `open`, the feature `shipped` with a
  "did it fire?" line
- A completed Closeout, archived workspace, swept archive

## Notes

The reflection is the habit that keeps the kit alive. Doing it at land time —
not "someday" — is what turns one-off lessons into durable, shared workflow.
