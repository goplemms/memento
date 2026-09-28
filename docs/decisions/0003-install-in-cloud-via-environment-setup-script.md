# ADR-0003: Install memento in cloud sessions via the environment setup script

- **Status:** Accepted
- **Date:** 2026-09-28
- **Amends:** ADR-0001 (the cloud half of "installs everywhere")

## Context

ADR-0001 assumed a repo's `.claude/settings.json` (`extraKnownMarketplaces` +
`enabledPlugins`) would auto-install the kit in cloud sessions. It doesn't.
Claude Code's docs say a cloud session doesn't install the plugins or
marketplaces a repo declares, because doing so needs the workspace trust
dialog, and cloud sessions never show it. Project threads start above the repo
clone and don't read repo settings or hooks at all.

A usage review (2026-09) found the result: cloud sessions ran either nothing or
a stale `memento@synced` copy uploaded to claude.ai in July. That copy's skills
have no frontmatter, so they never auto-trigger. The SessionStart hook that ran
`claude plugin update` had nothing to update, because no marketplace was ever
registered. And `plugin.json` pinned `"version": "0.2.0"`, which stops
`claude plugin update` from seeing new commits even where the plugin was
installed.

## Decision

- Cloud sessions get memento from the **cloud environment's setup script**:
  `claude plugin marketplace add goplemms/memento` then
  `claude plugin install memento@memento`. The script runs before Claude Code
  starts, so the plugin loads in every session of that environment, whatever
  the repo. Verified in a cloud VM on 2026-09-28: all 11 skills and 5 agents
  load, and this copy takes precedence over the stale `memento@synced` copy.
- Track `main`, protected by a GitHub ruleset that requires a pull request.
  Don't pin a tag.
- Drop `version` from `plugin.json` so each commit is a new version.
- Remove the repo's SessionStart refresh hook. Keep the repo settings keys in
  map form (`{"memento@memento": true}`) for local sessions only.

## Alternatives considered

- **Upload to claude.ai (synced plugin).** It loads everywhere, but every
  release needs a manual re-upload, and a forgotten upload is exactly how the
  stale copy happened.
- **Pin a tag in the setup script.** Gives exact control over releases, but
  costs an edit per release. A protected `main` gives most of the same safety.
- **Commit skills into each repo's `.claude/skills/`.** Forks the kit per repo,
  which ADR-0001 already rejected.

## Consequences

- **Easier:** one setup-script line per environment covers every repo in it.
  Nothing per repo.
- **Lag:** the environment caches the setup script's result for about seven
  days, so a merge reaches new sessions within a week. Editing any line of the
  script (a date comment) rebuilds the cache on the next session.
- **Owed:** `main` needs a ruleset (require PR, block force-push and deletion),
  because anything merged there reaches every new cloud environment. The stale
  claude.ai upload should be removed, or left in place knowing the marketplace
  copy shadows it.
- **Revisit if:** Claude Code starts honoring repo-declared plugins in cloud
  sessions, or the environment cache stops re-running the setup script.
