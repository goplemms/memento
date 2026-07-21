# Example: Codebase Audit

*One instance of the skill — auditing a media app for a class of data-access
inconsistency after a single symptom exposed it. The shape: a triggering symptom
→ a read-only agent along one lens → severity-ranked findings → one systemic root
fix that collapses a cluster of them.*

## Context

A media app kept two catalogs: a coarse `media_entries` table (per-creator / per-download
rows) and a per-file `media_files` index that the Library UI actually browsed. A new
"tag these albums" feature returned *"no media found"* on a curated library. The one
symptom smelled systemic — album expansion read `media_entries` by an `id LIKE 'path/%'`
that curated files (which live only in `media_files`) never matched. Before patching the
one call site, the question was: *how many other features read the wrong catalog?*

## Prompt

Follow `skills/codebase-audit/SKILL.md`.

**Lens:** data-access inconsistency between the two catalogs (`media_entries` coarse vs
`media_files` per-file), reconciled by path but never by a shared key.
**Symptom:** album tag-expansion queries `media_entries WHERE id LIKE 'path/%'` and
returns empty for browsed files, which live in `media_files`.
**Invariant:** ADR-001 — never flip `media_entries` to per-file granularity in place
(Plex symlinks + creator tags depend on the coarse rows).

Dispatch a read-only `general-purpose` agent (background). Modify nothing. Return
severity-ranked findings (Critical→Low) with `file:line`, the wrong assumption, the
user-visible symptom, and a fix direction — then a single systemic root-fix
recommendation and the invariants that constrain it.

## Expected Shape

- Findings ranked, not a match dump. e.g.:
  - **Critical** — album expansion + the tagger both key on `media_entries`, blind to
    browsed files → curated library tags nothing (`db.py:2286`, `autotagger.py:199`)
  - **High** — `tag_suggestions` has no FK; purge/delete leave orphans; approving one
    whose media is gone returns `{ok:true}` applying nothing
  - **High** — a tag merge re-points `entity_tags` but cascade-deletes `media_tags`,
    and `get_media_metadata` reads `media_tags` → merged tag silently vanishes
  - **High** — two soft-delete namespaces never reconcile → trashed tagged files still
    appear in search
- **A systemic recommendation**, the payoff: *drive per-file selection off `media_files`
  and promote to a path-keyed `media_entries` row on demand* — one root fix that
  collapses the Critical cluster — **plus** the invariant it must honor (additive rows
  only; never rewrite the coarse per-creator rows).
- Verification caught the audit over-reaching on a couple of line numbers; those were
  dropped, the rest kept with evidence.
- Triage: root fix driven through `memento:orchestrate`; the High findings became their
  own milestones; minors filed as follow-ups.

## Notes

- The lens was narrow ("read store A, data in store B"), so the report was a punch-list,
  not mush. "Audit the database" would have returned noise.
- Each fix was then run through `memento:challenge` — which is what caught that the
  orphan-cleanup fix covered only two of *four* deletion paths, and that the trash-hiding
  fix missed the UUID-keyed download case. The audit finds the class; challenge proves the
  fix covers all of it.
- A second run (a tactics-game repo, convention/terminology-drift lens, six scoped
  agents in parallel) confirmed the shape and sharpened three steps: challenging the
  fix-list *before building* reversed one fix outright (a throw-on-duplicate that would
  have broken a deliberate double-load idempotency) and rejected a proposed synthetic
  "model file" as a drift surface; baselining against the repo's prior refactor canon
  showed drift lived exactly where no guard reached — so every systemic fix shipped
  with a named tripwire; and one subagent finding reproduced while another didn't,
  which is why "verify before trusting" is a step, not a nicety.
