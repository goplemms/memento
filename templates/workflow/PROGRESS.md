# Progress: <FEATURE_NAME>

Resume/survival file. If context is lost, this page alone should let work resume.

## Status

| Milestone | State |
|-----------|-------|
| M1 — <name> | todo |
| M2 — <name> | todo |

States: `todo` → `in-progress` → `testable` → `done`
(`testable` = code complete, awaiting user-testable gate confirmation.)

## Current block

- **Milestone:** <which milestone is active>
- **Last green sha:** <commit sha where tests last passed>
- **Next step:** <the single next action>
- **Blockers:** <none | what is blocking>

## Queue

Corrections and tweaks the user made mid-step, in arrival order, one `- `
item each. Finish the current step, then work them top down, and delete
each item once done. A correction that says the current step is wrong is not
queued: it is a pivot or adjustment (see `decisions.md`).

## Kit gaps

Each mistake the user corrected that traces to an instruction: which one (a
skill, CLAUDE.md, the plan) and the fix you'd propose, one `- ` item each.
`memento:land` reads this at reflection.

## Review ledger

One row per milestone, added once its review is done: what reviewed it, what
it found, and what was folded in. For a trivial change, add the row anyway
with `skipped: <why>` under **Reviewed by**, so a skipped review is visible
instead of silent.

While a milestone is `in-progress` or `testable`, `hooks/review-gate.sh` stops
`git commit` until this table has a row for it. The match is on the
milestone's first word, such as `M2`.

| Milestone | Reviewed by | Found | Folded in |
|-----------|-------------|-------|-----------|

## Closeout

Filled in only when the feature is finished. `archive-feature.sh` REFUSES to
archive until this section is complete.

- **Graduated to:** <commit body | architecture doc | README | nothing (spike) | memento (workflow asset improved)>
- **Issues:** <this feature's idea issue and those filed for leftovers, as #N or owner/repo#N (docs/ideas.md); or, for a spike with no issue and no leftovers, none: plus the reason>
- **Archived:** <no | yyyy-mm-dd>
