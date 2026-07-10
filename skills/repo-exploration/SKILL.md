---
name: repo-exploration
description: Quickly understand an unfamiliar repository before proposing changes — inspect only what's needed, summarize the codebase shape, and name the smallest useful next action. Use when starting work in a repo you don't know, or before proposing any change.
when_to_use: Starting a task in an unfamiliar repo; before proposing or planning a change; when you need the lay of the land without reading everything.
---

# Repo Exploration

## Purpose

Help Claude Code quickly understand an unfamiliar repository before proposing changes.

## Inputs

- the user goal
- the current repo state
- a small list of likely relevant files or folders

## Process

1. Restate the goal in one sentence.
2. Inspect only the files needed to understand the request.
3. Summarize the current shape of the codebase in plain language.
4. Identify the smallest useful next action.
5. Avoid broad exploration if a narrow answer is enough.

## Outputs

A short summary of what matters, what is missing, which files were inspected, and what file or area should be touched next.

## Notes

This skill is intentionally conservative. It should reduce thrash and help Claude Code avoid reading too much too early. Explicitly naming inspected files makes it easier to tell whether the skill stayed scoped.
