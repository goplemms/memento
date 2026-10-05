---
name: ship
description: Take finished work from a branch to merged — commit what's staged by name, open a PR that leads with a plain-language summary, watch CI to green, fix what breaks, and merge only when the user says to; then confirm any deploy and tidy what's left on the branch. Use when the user says "PR this", "PR and merge", "check CI and merge if green", "push our changes", or "clean up the branch".
when_to_use: The work is done and the user wants it committed, PR'd, merged, or deployed; the user asks to check CI and merge; the user asks what is left on a branch to PR, adapt, or drop.
---

# Ship

## Purpose

Carry finished work from a branch to a merged, deployed result without the user
having to type out each step. Usage data showed this was the most repeated
hand-typed procedure: "PR and merge", "check the CI and then merge if
successful", and "verify what's left in this branch to PR, adapt, or eliminate".

`memento:land` calls this for its merge step. Use it on its own for any change
that doesn't need land's reflection ritual.

## Inputs

- A branch with finished work (committed or staged)
- The repo's conventions: default branch, PR template, CI, deploy workflow
- The user's words for how far to go: commit, PR, merge, or deploy

## Process

1. **Take stock.** Run `git status` and diff the branch against the default
   branch. List what is committed, what is staged, and what is loose. Stage by
   name, never `git add -A`, and never commit secrets or scratch files.
2. **Commit** in the repo's message style.
3. **Open the PR.** Use the repo's PR template if it has one. Otherwise lead with
   a tweet-length (≤280 characters) plain-language summary of what the change
   gets the reader, then short bullets, then the technical detail under its own
   heading (the prose form of `${CLAUDE_PLUGIN_ROOT}/docs/tldr-convention.md`;
   worked example in `examples/land.md`).
4. **Watch CI.** Wait for it to finish rather than guessing. When it fails, read
   the log, reproduce locally, fix the root cause, and push. Never skip or
   disable a test to get green, and never retry a real failure as a "flake".
   If the failure is also red on the default branch, say so with the evidence
   instead of widening the PR.
5. **Merge only on the user's word.** "PR and merge" or "merge if green" counts
   as that word once CI is green. Anything else stops at a green PR and asks.
   Use the repo's merge style (squash, merge commit, or rebase).
6. **Confirm the deploy** when the repo has one: watch the deploy run and check
   the live result (a URL, a health check, a version string). Report what you
   saw, not what should have happened.
7. **Tidy the branch.** List what's left on it that didn't ship. For each item
   propose one of: PR it, adapt it, or drop it. Act only on the user's choice.
   Delete the branch after merge if that's the repo's habit.
8. **Reflect, briefly.** After the merge, ask one question while context is
   fresh: what in the kit helped this change, and what got in the way? Write
   the answer in one or two lines, in the PR as a comment or, inside a feature,
   in `PROGRESS.md`'s Closeout. If the answer names a kit asset to change, say
   so; `memento:land` and the monthly skills-mining routine pick those up. Skip
   it for a one-line fix, and say you skipped it.

## Outputs

- A merged PR, or a green PR waiting on the user's word
- The CI and deploy results as observed, with links
- A short list of anything left on the branch and what was decided for it
- A one- or two-line reflection: what helped, what got in the way

## Notes

- Merging and deploying are outward-facing and hard to undo. Take "merge" or
  "deploy" from the user's own message, never from a guess about what they'd
  want.
- On a repo where CI costs money (GitHub Actions minutes), prefer batching
  related work onto one branch and one PR over many small ones, when the user
  has said so.
- If the repo has no CI, say that plainly instead of calling the PR "green".
