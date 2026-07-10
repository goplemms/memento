# ADR-0001: Adopt public plugin distribution for the kit

- **Status:** Accepted
- **Date:** 2026-07-10
- **Update:** the `--user` symlink and `--vendor` install paths described here as
  kept "in reserve" are retired by [ADR-0003](0003-plugin-only-distribution.md);
  the plugin is now the sole channel. The plugin decision itself stands.

## Context

memento distributes itself by symlinking `skills/`, `personas/`, and
`templates/` into `~/.claude` on a single machine (`install.sh --user`), with a
`--vendor` copy path for anywhere symlinks won't reach. The identity guarantee
— "editing `~/.claude` IS editing memento" — depends entirely on those symlinks
existing on one physical box.

Our actual working environment is cloud-first and ephemeral (Claude Code on the
web). In an ephemeral container there is no `~/.claude` symlink, nothing on
PATH, and `/orchestrate` does not resolve — so in the environment we use most,
the kit effectively does not exist. The symlink model has near-zero coverage
where we live, and the fallback (`--vendor`) is the worst of both: it forks and
drags the manual `workflow-sync` drift ritual.

Two problems follow: (1) getting the kit *into* ephemeral sessions reliably, and
(2) getting improvements discovered mid-session *back* to canonical, which the
symlink-commit loop cannot do in the cloud.

## Decision

Adopt Claude Code **plugin** distribution as memento's primary channel, hosted
from a **public** git marketplace, and add a **phone-home** skill that upstreams
kit improvements to memento as pull requests.

- **Plugin, public marketplace.** memento becomes a plugin declared in a
  consuming repo's `.claude/settings.json`; Claude Code auto-installs it at
  session start, including in cloud sessions. Public hosting means token-free
  install (cloud's default Trusted access reaches GitHub) — the simplest
  possible ops.
- **Decisions stay private and in-repo.** The kit being public does not make
  decisions public. ADRs live in each consuming repo's `docs/decisions/`; those
  repos stay private independently.
- **Phone-home is a PR, with neutrality gates.** A session that improves a kit
  asset opens a PR against memento (via the GitHub API — no clone needed). To
  keep it project-neutral: **generalize-or-reject** (an improvement that only
  fits one project stays local), **category-only provenance** (never an
  identifying project noun), a **mandatory denylist gate** that scans the diff
  *and* the commit/PR text, and **human approval on every merge**.

Scope for now is **decisions-only** on the project-management side: task
tracking stays in the local scratchpad; only decisions graduate (to ADRs). Full
plugin migration is accepted here but not yet executed.

## Alternatives considered

- **Keep `--user` symlinks.** Optimal for a solo, single-machine kit; but that
  is not our environment. Absent in cloud — the case we most need.
- **`--vendor` copies everywhere.** Works in ephemeral envs but forks and
  requires manual drift reconciliation. The plugin retires this path.
- **SessionStart hook that clones the kit per session.** Viable stopgap and
  fixes the "no kit in this container" case, but no versioning and re-runs every
  session. Kept in reserve, not the primary channel.
- **Private plugin marketplace.** Fully supported, but needs a `GITHUB_TOKEN`
  present in the cloud environment for auto-install. Chosen against because a
  content audit found the kit is generic tooling safe to publish, and public
  removes the token setup entirely.
- **Other PM tools (GitHub Issues/Projects, Linear, Notion).** Right for the
  task-tracking half later, but out of scope for the decisions-only first step,
  and none beat in-repo ADRs for versioned, greppable decisions.

## Consequences

- **Easier:** the kit installs — versioned and reproducible — in every
  environment we use, including ephemeral cloud sessions, with no token or
  symlink setup. Improvements have a real path home (PR) with review, replacing
  the symlink-commit loop that never worked in the cloud.
- **Simpler:** the `--vendor` fork path and most of `workflow-sync`'s reason to
  exist can be retired — net machinery goes down, not up.
- **Owed / harder:** a one-time migration — path resolution via the plugin-root
  env var in scripts and template-referencing skills, a decision on whether
  personas become plugin `agents/`, and a naming pass (`/orchestrate` →
  `memento:orchestrate`) with doc updates. Public hosting requires permanent
  **provenance hygiene** on phone-home PRs; the denylist gate must cover commit
  and PR text, not just diffs. (A real instance of this leak — an internal
  codename surviving in a genericized upstream commit *message* — is why that
  gate is mandatory rather than advisory.)
- **Revisit when:** the plugin subsystem's precedence/auth semantics shift under
  us in a way that breaks resolution, or a need arises to keep the kit private
  (sensitive content starts flowing through it) — at which point supersede with
  a private-marketplace + token ADR.
