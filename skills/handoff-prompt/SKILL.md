---
name: handoff-prompt
description: Write a self-contained, copy-paste prompt that lets a fresh session pick up this work cold — what to read first, where the work is, the first task, how to work, the traps already found, and the constraints. Use when the user asks for "a copy-paste prompt", "a prompt to pick this up fresh", "a prompt to orchestrate these changes", or when a session is ending with work left.
when_to_use: The user asks for a prompt to continue, hand off, or parallelize work in a new session; a session is winding down with open work; work needs to move to a session with different access (internet, another repo).
---

# Handoff Prompt

## Purpose

Let a fresh session with none of this conversation's context continue the work
without re-deriving what was already learned. Usage data showed this as the
second most repeated hand-typed ask ("May I request a copy-paste version",
"a prompt to pick this up fresh from main").

## Inputs

- The goal and where the work stands right now
- The branch, PR, or issue the next session starts from
- Decisions already made, and why
- Traps found along the way: things that looked true and weren't

## Process

1. **Check the ground truth first.** Confirm the branch is pushed, and note the
   last commit and whether the gates (tests, lint, typecheck) are green. A
   prompt that points at unpushed work is broken on arrival.
2. **Record anything durable where it belongs** before writing the prompt, such
   as an issue comment or an ADR. The prompt should point at that record, not
   be the only copy of it.
3. **Write the prompt** in one fenced block with these sections, skipping any
   that would be empty:
   - **Opening line:** who the reader is and what they are picking up.
   - **Read first, in this order:** the files, ADRs and issues (with the
     comments that supersede the body), each with one line on why.
   - **Where the work is:** branch, last green commit, what's done, and what's
     deliberately incomplete. Say "do not start from main" when that's true.
   - **Your first task:** the next step, what's already decided ("implement,
     don't re-litigate"), and how to tell it's right (expected outputs or
     numbers).
   - **How to work:** the working agreements that apply, such as measure before
     and after, write a failing test first, report honestly.
   - **Traps:** what looked true and wasn't, so the next session doesn't
     rediscover it.
   - **Constraints:** the branch to use, what not to push or open without
     asking, and anything owed in a separate PR.
   - **After this:** the rest of the queue, in order.
4. **Make it self-contained.** No "as above", no "this conversation", no
   references the reader can't open. Use full paths, issue numbers, and commit
   SHAs.
5. **Challenge it.** Reread it as a session with zero context would. Could it
   start work from this alone? Fix every place it would have to ask.

## Outputs

- One fenced, copy-paste prompt
- A note of where the durable record was written (issue comment, ADR)

## Notes

- Aim for the shortest prompt that works. The reading list carries the detail;
  the prompt carries the order and the decisions.
- To split work in parallel, write one prompt per session and name each one's
  branch and files, so the sessions don't collide (see
  `memento:decompose-to-issues` for the collision map).
