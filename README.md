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

### Install (as a plugin)

memento ships as a self-hosting Claude Code plugin — the sole install channel.
It installs the same way everywhere, including cloud/web sessions.

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

Skills install namespaced, e.g. `memento:orchestrate`; the plugin's `bin/`
scripts (`new-feature.sh` etc.) are on the Bash tool's PATH. See
`docs/decisions/0001-adopt-public-plugin-distribution.md` and
`docs/decisions/0003-plugin-only-distribution.md` for the why.

### Daily loop

```sh
new-feature.sh my-feature --with-decisions   # scaffold scratchpad/my-feature
# ... drive with memento:orchestrate: plan.md -> milestones -> memento:land ...
archive-feature.sh my-feature                # refuses without a Closeout
sweep-archive.sh                             # dry-run GC of old archives
```

The workflow is identical across every repo because they all resolve the same
plugin version. Improvements to a kit asset go home as a **phone-home PR**
against memento — project-neutral and human-approved.

## Design Rules

- Prefer markdown over tooling.
- Keep assets short and readable.
- Format skills around `Purpose`, `Inputs`, `Process`, and `Outputs`.
- Add only one good example before adding more structure.
- Optimize for Claude Code first.
- Leave room to support other agents later without changing the core layout.
