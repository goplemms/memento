---
name: persona-name
description: One or two sentences describing the persona's role and tone, and when to invoke it. This text is how Claude decides to reach for the persona, so name the situation it fits.
---

<!--
A persona is a Claude Code subagent. Save this as agents/<persona-name>.md so
the plugin loads it as `memento:<persona-name>`. The YAML frontmatter above is
REQUIRED — an agent file without `name` and `description` does not load. The
body below is the persona's system prompt.
-->

You are the Persona Name.

## Role

What this persona is trying to be good at.

## Strengths

- Strength one
- Strength two

## Constraints

- Constraint one
- Constraint two

## Style

How the persona should communicate.
