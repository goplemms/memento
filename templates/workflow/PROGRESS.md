# Progress: <FEATURE_NAME>

Resume/survival file — the one page that lets work resume after context loss.
Keep it current; in an ephemeral container, commit or push it at each milestone
boundary, or it won't survive a disposable workspace.

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

## Closeout

Filled in only when the feature is finished. `archive-feature.sh` REFUSES to
archive until this section is complete.

- **Graduated to:** <commit body | architecture doc | README | nothing (spike) | memento (workflow asset improved)>
- **Archived:** <no | yyyy-mm-dd>
