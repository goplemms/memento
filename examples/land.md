# Example: Land — the PR description convention

## Context

A feature is done and its merge opens a PR. The instinct is to describe the PR the way the *diff* reads — module names, function names, a file list. But most readers (a teammate, a reviewer, future-you) first need to know **what the change gets them and whose work it eases** — not what files moved. `land` step 1 asks the description to lead with that, tweet-length, above the technical fold.

## Prompt

Follow `skills/land/SKILL.md` step 1. Write the PR description so it **leads** with a ≤280-char, plain-language summary of what the change gets the reader and whose work it eases — no jargon, altitude above the file list. Add ~10-word bullets only where they earn it. Put the technical detail (modules, APIs, test counts) below that, under its own heading.

## Expected Shape

**Before** (reads like the diff — what NOT to lead with):

```text
Adds authored-catalog.ts with injectAuthoredNodes/getAuthoredNode, makes
AuthoredExpedition.encounters optional, adds resolveAuthored + a load pipeline
(validateExpedition + prerequisiteProblems + loadExpedition), MapNode.provides/
requires, and wires RescueBootScene through the injected catalog. 24 files, +1803/-20.
```

**After** (leads with the payoff, jargon below the fold):

```text
Authored levels used to live in two incompatible places, and moving one between
them meant retyping it by hand. This makes it one source of truth — and a broken
level now fails the build with a clear error instead of freezing a player.

- Author a level once; drop one file, used everywhere.
- Typos and dead links caught at build time, not by a player.
- Eases the level designer's work; kills a class of freeze bugs.

## Technical detail
<modules, APIs, test counts, migration notes — here, not up top>
```

## Notes

The test: could a non-author of the code read the first paragraph and say who's better off and why? If it only makes sense to someone who's read the diff, it's still at file-list altitude — raise it. Bullets are optional and earn their place at ~10 words; prose is fine when the summary already lands. The technical detail is not omitted — it moves **below** the summary, so reviewers still get it.
