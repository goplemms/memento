---
name: workflow-name
description: One or two sentences describing the end-to-end sequence this workflow drives and when to run it. Name the starting state so Claude reaches for it at the right moment.
---

<!--
A "workflow" in this kit is just a skill that sequences other skills and
personas. There is no separate plugin `workflows/` directory — a plugin only
propagates skills, agents, commands, hooks, and MCP servers. So author a
workflow the same way as any skill: save this as
skills/<workflow-name>/SKILL.md with the frontmatter above, and reference the
assets it composes by their namespaced names (memento:<name>).

`orchestrate` and `iterate-on-asset` are the two workflows in the kit today —
both live in skills/.
-->

# Workflow Name

## Purpose

What outcome this workflow produces, and which skills/personas it composes
(e.g. `memento:repo-exploration`, `memento:curious-builder`).

## Inputs

- The starting state the workflow assumes

## Process

1. Start state
2. Main loop — hand off to the composed skills in order
3. Finish condition

## Outputs

What should exist when the workflow is done.

## Notes

Keep the sequence thin. If a step is really its own focused job, make it a
separate skill and call it from here rather than inlining it.
