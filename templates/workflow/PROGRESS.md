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
- **Archived:** <no | yyyy-mm-dd>
