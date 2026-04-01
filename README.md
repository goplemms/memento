# Thin Claude-First Tooling Library

This repository is a small place to collect and refine agentic assets for Claude Code.

It starts thin on purpose. The goal is to capture useful shapes, try them in practice, and improve them through discussion instead of filling out a large framework upfront.

## What Lives Here

- `skills/`: reusable instructions for a focused task
- `workflows/`: short multi-step patterns that compose assets
- `personas/`: reusable role and tone definitions
- `practice-areas/`: small sandboxes for trying prompts and workflows
- `examples/`: concise usage examples for Claude Code
- `evals/`: lightweight checks for whether an asset is helping
- `templates/`: starter shapes for writing new assets
- `docs/`: small notes about structure and evolution

## Quick Start

1. Read `docs/architecture.md`.
2. Copy a file from `templates/`.
3. Create one small asset.
4. Try it in a practice area.
5. Capture what worked in `examples/` or `evals/`.

## Design Rules

- Prefer markdown over tooling.
- Keep assets short and readable.
- Add only one good example before adding more structure.
- Optimize for Claude Code first.
- Leave room to support other agents later without changing the core layout.
