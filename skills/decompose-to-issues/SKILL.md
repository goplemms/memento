---
name: decompose-to-issues
description: Turn one feature or plan into a set of tracker issues that can actually be worked in parallel — decomposed along real code seams, labelled by phase so a partial slice is independently closeable, collision-mapped so concurrent sessions do not conflict, and put through a review gate that catches defects within and between the issues before anyone implements. Use when a plan needs to become a backlog, or when inheriting a backlog written before the code existed.
---

<!--
Save as skills/decompose-to-issues/SKILL.md so the plugin loads it namespaced
(memento:decompose-to-issues). Composes the `memento:backlog-reviewer` agent for
its review gate. Produces issues and a sequence, not code.
-->

# Decompose to Issues

## Purpose

Get from "here is a feature" to "here are N issues, in this order, that N
sessions can work without colliding, and each of which is honest about what it
actually requires." The deliverable is a reviewed, sequenced, phase-labelled
backlog — not an implementation.

The failure this exists to prevent: issues written *before* the code, handed
straight to implementers, that quietly disagree with the codebase and with each
other. They read authoritatively, they get trusted, and the cost surfaces as
rework two sessions later.

## Inputs

- The **feature or plan** to decompose (a `plan.md` from `memento:discussion-to-plan`, a
  design doc, or a conversation).
- The **repo** — the code is the source of truth for every claim an issue makes.
- The **tracker** and its existing **label vocabulary**. Match the conventions
  already there (`area:`, `type:`, `priority:`) rather than minting a parallel scheme.
- Any **invariants** implementers must not break (architecture rules, ADRs).

## Process

1. **Verify the shared premise before decomposing anything.** Whatever every
   issue will assume — the base branch, the scaffold, a schema, a running
   environment — confirm it exists and is in the state you think. If it is not,
   that is issue zero, and it usually belongs to nobody yet.

2. **Decompose along seams that already exist in the code**, not along an org
   chart or a wish list. A good issue boundary is a module boundary, a protocol,
   or a contract — something with a real edge. If two "separate" issues both have
   to edit the same model file to start, they are one issue, or one of them is
   really a prerequisite that should land first.

3. **Map the collision surface before writing a single issue body.** For each
   file likely to change, list the issues that touch it. Wherever more than one
   does, decide now: one owner and a stated order, or merge them. Shared modules
   (a URL serializer, a formatter, a CI workflow, a domain model) are where
   parallel sessions actually collide, and the map is cheaper than the merge.
   **A coordination issue that lands a shared shape once, before the issues that
   depend on it, is worth its own ticket** — and its entire value is landing
   first. Say so in it.

4. **Choose the phase boundary and make it a label.** Most features have a seam
   where a large slice can be completed against something cheaper than the real
   dependency — mocked data, a frozen contract, a dev-mode stub, a fixture. Name
   that seam, define a label pair for it (e.g. `scope:mock` / `scope:real-data`),
   and apply it. The point is that a session can finish a phase and *stop*,
   knowing it is done, without judging for itself where the boundary was.

5. **Split by phase into separate issues, not sections within one issue.** A
   "Phase A / Phase B" heading inside one body reads as one ticket no matter what
   the heading says, and gets worked as one. Instead: the parent keeps the full
   design and becomes the later phase; a child issue carries the closeable slice,
   links back, and is labelled with the phase. Use the tracker's real
   parent/child mechanism (sub-issues, epics) so the relationship is structural
   rather than a sentence someone has to notice. Then put a comment on the
   parent stating exactly what remains once the child closes.

6. **Make each phase's criteria checkable within that phase.** This is the test
   of whether the split is real: if a child issue's acceptance criteria cannot be
   ticked without the thing the phase was supposed to defer, the boundary is in
   the wrong place. Move it.

7. **Guard any phase built on fakes.** State where fakes may live (tests and dev
   fixtures) and what must happen without the real dependency (an explicit
   failure, never plausible-looking output). A mocked slice wired into a shipped
   path is exactly the "fake data that looks real" failure, and it is easiest to
   introduce at the phase seam.

8. **Run the review gate.** Dispatch `memento:backlog-reviewer` (read-only) over
   the whole set plus the repo, before anyone implements. It checks each issue
   against the code it cites and every issue against the others: contradicted
   premises, phantom dependencies, duplicate ownership, unverifiable criteria,
   collisions, gaps. Do this even for issues you just wrote — the cross-issue
   axis is invisible from inside any one of them.

9. **Fix in place, and leave a changelog.** Correct the issue bodies so the next
   reader gets the truth first; add a short comment per issue saying what changed
   and why. A correction that only lives in a comment loses to the body text
   above it. Where a finding is a *decision* rather than a defect, take it to the
   human rather than picking silently.

10. **Sequence by what unblocks the most, and start the longest-lead item now.**
    Rank by unblock-count, not by interest. Separately, identify anything
    calendar-bound rather than effort-bound — a vendor conversation, a
    procurement, an access request — and start it immediately regardless of where
    it sits in the dependency order, because its clock runs whether or not you
    are working on it.

## Outputs

- A set of issues, each verified against the code, with real dependencies and
  single owners for shared files.
- A phase label pair applied, with parent/child links for anything split.
- A file collision map and a stated order for contended files.
- A dependency-ordered sequence naming what can start now, what is genuinely
  blocked, and what merely looks blocked.
- A review report with each finding resolved, corrected, or escalated, led by a
  TL;DR block — ≤5 bullets, ≤10 words each, no jargon, paths, or symbol names:
  what the gate caught, what it changed, what needs the human's call. See
  `${CLAUDE_PLUGIN_ROOT}/docs/tldr-convention.md`.

## Notes

- **The review gate is the point.** Decomposition without it produces a tidy-looking
  backlog whose issues disagree with the code and each other. If you only do one
  step from this skill, do step 8.
- **"Merely looks blocked" is the highest-value output.** Stated dependencies are
  written defensively and are routinely stricter than the files require. Every
  phantom blocker you retire converts serial work into parallel work at no cost.
- **Do not let the label do the demarcation's job.** A `scope:mock` label on an
  issue whose body still describes the whole feature tells a session nothing about
  where to stop. The label routes; the split defines.
- **Corrections are outward-facing.** Editing someone's issues changes shared
  state. Agree the mechanism (edit bodies, comment, or both) before doing it at
  scale, and prefer fixing the body so the wrong text stops being the first thing
  read.
- **Verify your own claims through a second path before publishing them.** If a
  finding rests on what a tool showed you — text missing, a field absent, a file
  empty — confirm it another way first. Read paths sanitise and re-render; a
  correction issued against a rendering artifact is worse than the defect, because
  it churns real work and has to be retracted publicly.
- **Pairs with `memento:challenge`.** This skill hardens the *plan of record*;
  challenge hardens what gets built from it.
