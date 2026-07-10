# Thin Claude-First Tooling Library

This repository is a small place to collect and refine agentic assets for Claude Code.

It starts thin on purpose. The goal is to capture useful shapes, try them in practice, and improve them through discussion instead of filling out a large framework upfront.

## What Lives Here

- `skills/`: reusable instructions for a focused task
- `workflows/`: short multi-step patterns that compose assets
- `agents/`: task-delegated subagents Claude Code can hand a job to (e.g.
  `decision-adversary`)
- `personas/`: reusable role and tone definitions
- `practice-areas/`: small sandboxes for trying prompts and workflows
- `examples/`: concise usage examples for Claude Code
- `evals/`: lightweight checks for whether an asset is helping
- `templates/`: starter shapes for writing new assets
- `docs/`: small notes about structure and evolution

## Quick Start

1. Read `docs/workflow-guide.md` to see which skills and workflows to fire and when.
2. Read `docs/architecture.md`.
3. Copy a file from `templates/`.
4. Create one small asset.
5. Try it in a practice area.
6. Capture what worked in `examples/` (one concrete file per skill) or in `evals/`.

## Workflow Kit

memento is also the single source of truth for a lean planning workflow.

### Install as a plugin (recommended; works in cloud/ephemeral sessions)

memento ships as a self-hosting Claude Code plugin, so it installs the same way
everywhere — including cloud/web sessions where `~/.claude` symlinks don't exist.

```sh
/plugin marketplace add goplemms/memento
/plugin install memento@memento
```

Or declare it in a consuming repo's `.claude/settings.json` so every session
(including cloud sessions) auto-installs it:

```json
{
  "extraKnownMarketplaces": {
    "memento": { "source": { "source": "github", "repo": "goplemms/memento" } }
  },
  "enabledPlugins": { "memento@memento": true }
}
```

Skills install namespaced, e.g. `memento:orchestrate`. See
`docs/decisions/0001-adopt-public-plugin-distribution.md` for the why.

### Install via symlink (single machine)

For a single dev machine, the symlink install makes editing `~/.claude` the same
as editing memento directly:

```sh
./install.sh --user            # symlink skills/personas/templates -> ~/.claude,
                               # bin/*.sh -> ~/.local/bin (existing targets backed up)
./install.sh --user --dry-run  # preview without changing anything
./install.sh --uninstall       # remove links, restore most recent backup
```

Because the install symlinks the live files, editing a skill in `~/.claude` IS
editing memento — commit it here and every repo on the machine sees it. Ensure
`~/.local/bin` is on your `PATH`.

### Daily loop

```sh
new-feature.sh my-feature --with-decisions   # scaffold scratchpad/my-feature
# ... drive with /orchestrate: plan.md -> milestones -> /land reflection ...
archive-feature.sh my-feature                # refuses without a Closeout
sweep-archive.sh                             # dry-run GC of old archives
```

The workflow is identical across every repo because they all resolve the same
symlinked canonical files. The one thing that breaks this — a project-scope
`.claude/skills/<name>` shadowing the kit — is detected and warned about by
`install.sh`, `/workflow-init`, and `/workflow-sync`.

## Design Rules

- Prefer markdown over tooling.
- Keep assets short and readable.
- Format skills around `Purpose`, `Inputs`, `Process`, and `Outputs`.
- Add only one good example before adding more structure.
- Optimize for Claude Code first.
- Leave room to support other agents later without changing the core layout.
