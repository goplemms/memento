# ADR-0003: Retire the symlink install; make the plugin the sole channel

- **Status:** Accepted
- **Date:** 2026-07-10

## Context

ADR-0001 made the plugin memento's *primary* channel but deliberately kept the
`install.sh --user` symlink install and the `--vendor` copy path "in reserve,"
and predicted both could later be retired. This ADR executes that retirement,
now that the prediction has been checked rather than assumed.

What we confirmed:

- **The plugin loop works end-to-end on every mechanical link.** Manifests are
  valid; scripts resolve the kit root via `CLAUDE_PLUGIN_ROOT` (verified by
  running `new-feature.sh` inside a repo that is *not* memento and has no `bin/`
  on its PATH — it scaffolded and substituted correctly); `bin/` is added to the
  Bash tool's PATH; `agents/` auto-discover; skills resolve as `memento:<name>`
  (the directory name supplies the command, and an absent `description`
  frontmatter field falls back to the skill's first paragraph); the plugin
  actually enables in-session. The **phone-home PR** replaces the
  symlink-commit loop and is the one upstream path that works in the cloud.
- **The maintainer's environment is cloud-first / ephemeral**, where `~/.claude`
  symlinks do not exist — so the symlink channel had near-zero coverage where we
  actually work.
- **Personas were never a Claude Code primitive in any install mode.** Claude
  Code has no persona concept; personas are plain tone-guide files consumed by
  reference. The symlink install merely parked them at `~/.claude/personas/`, a
  path nothing referenced. So retiring symlinks removes no working mechanism.

Keeping two channels imposed a real, recurring tax: every new asset type had to
be threaded through `install.sh`'s `LINKED_DIRS`, and every doc and skill had to
speak in a dual voice (`memento:orchestrate` vs bare `/orchestrate`).

## Decision

Make the plugin the **sole** distribution channel.

- **Delete `install.sh`** (both `--user` symlink and `--vendor` copy paths). The
  plugin subsumes its whole job: assets auto-discover, `bin/` goes on PATH.
- **Retire the standalone `workflow-sync` skill.** Its drift-reconciliation
  purpose assumed vendored forks, which no longer exist; the shadow it guarded
  against is further defused by namespacing (a project `.claude/skills/foo` makes
  `/foo`, which no longer collides with `memento:foo`). Fold a slim shadow note
  into `workflow-init`.
- **Drop the identity-guarantee / reverse-drift framing** from the docs and
  collapse all invocation naming to the plugin form `memento:<name>`.
- **Upstreaming is exclusively the phone-home PR** (GitHub API, project-neutral,
  human-approved).
- **Personas remain an asset type**; from a consuming repo they are referenced
  via `${CLAUDE_PLUGIN_ROOT}/personas/…`.

This **supersedes the install-distribution parts of ADR-0001** (the `--user` and
`--vendor` reserve). ADR-0001's plugin decision stands and is now fully in force.

## Alternatives considered

- **Keep symlinks as a documented fallback.** Rejected: the dual-model tax is
  paid across every doc/skill, and the fallback has near-zero coverage in a
  cloud-first environment.
- **Slim `workflow-sync` instead of retiring it.** Rejected: once forks are gone
  and names are namespaced, its remaining shadow-scan is largely moot; a light
  check folded into `workflow-init` covers the residual migration case.
- **Wait for a cold-session proof before deleting.** Only one link —
  cold-marketplace auto-install — is still unobserved end-to-end; every other
  link is validated. Recorded as a caveat below rather than allowed to block.

## Consequences

- **Simpler:** one channel and one naming story. New asset types stop threading
  through `install.sh`; docs drop the dual-voice hedging; ~155 lines of
  `install.sh` and the whole `workflow-sync` skill are retired — net machinery
  goes down.
- **Owed / to watch:** **cold-marketplace auto-install** (add the memento
  marketplace in a genuinely fresh cloud session → confirm `memento:orchestrate`
  resolves) is validated by parts but not yet observed as one flow — confirm on
  the next real cloud session. Skills currently rely on the first-paragraph
  `description` fallback; giving each real `description`/`when_to_use` frontmatter
  is a recommended, channel-neutral follow-up. Personas are usable from consumer
  repos only via `CLAUDE_PLUGIN_ROOT` paths.
- **Revisit when:** a need arises to work offline / on a persistent single
  machine without the plugin, or the plugin subsystem's resolution or auth
  semantics shift — at which point supersede with a new channel ADR.
