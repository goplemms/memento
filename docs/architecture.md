# Architecture

This repo treats each asset type as a simple markdown building block.

## Relationships

- A `persona` shapes how the agent behaves.
- A `skill` helps the agent do one focused job well.
- A `workflow` combines skills and personas into a repeatable sequence.
- A `practice-area` provides a small place to test the workflow.
- An `example` shows how to invoke the asset in Claude Code.
- An `eval` records a simple way to check whether the asset was useful.

## Current Shape

The current structure is intentionally small:

- one example skill
- one example workflow
- one example persona
- one small practice area
- one example prompt file
- one sample eval

## Future Extension

If this grows beyond Claude Code, keep the core directories the same and add agent-specific notes inside assets or under a future `platforms/` or `adapters/` area. Do not introduce a larger abstraction layer until repeated friction makes it necessary.
