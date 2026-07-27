# Eval: Backlog Reviewer

## Asset Under Test

`agents/backlog-reviewer.md`, as fired by `skills/decompose-to-issues/SKILL.md` (step 8).

## Scenario

Point it at a tracker backlog written before the implementation existed, plus the repo the
issues cite. Ask for findings. The honest version of this eval needs a backlog with *known*
planted defects on both axes — the cheap way to get one is to run it against a real inherited
backlog and score it afterwards against what a careful human pass found.

## Success Signals

**Within-issue:**

- names at least one issue whose premise the code contradicts, and cites the commit or
  `file:line` that disproves it
- checks quantities (line counts, row counts, "a ~25-line block"), not just prose
- distinguishes a real gap from a deliberate omission by reading the Out-of-scope section
- flags acceptance criteria that cannot be checked in a PR, and says which kind — needs a real
  environment, self-contradictory, or references an unmade decision

**Between-issue — the axis that fails silently:**

- produces a file collision map with a recommended owner per shared file
- names at least one *phantom* dependency (stated blocker that the files do not require)
- catches duplicate ownership where two issues each specify the same deliverable
- finds a gap by following a data dependency ("three issues consume X; which produces X?")
  rather than by reading titles

**Discipline:**

- verifies the shared premise every issue assumes *before* reviewing individual issues, and
  leads with it if broken
- reports "could not verify" explicitly rather than passing an unchecked claim through
- edits nothing

## Result

Mixed — the shape held, one class of finding was wrong.

Run against a 26-issue backlog for a scaffolded-but-unbuilt monorepo. It found the broken
shared premise (the scaffold was on an unmerged branch; `main` was a one-line README), three
already-fixed "bugs to fix", a systematic rule-renumbering across ten issues, two duplicate
ownerships, a phantom dependency, and a real gap (three issues consumed fundamentals data
that nothing ingested). Collision map and dependency corrections both produced.

**The failure:** it reported that placeholder text had been stripped from several issue
bodies. It had not — the tracker's *read* API silently drops unrecognised tag-like sequences,
so only the rendering was damaged. The bad finding produced an unnecessary body edit and six
correction comments, all publicly retracted.

## Notes

The failure is the useful part, and it is now a constraint in both assets: **confirm through
a second path before reporting a finding that rests on tool output** — especially findings of
the form "this is missing", since absence is exactly what a sanitising read path manufactures.

Worth checking on the next run: does the agent actually honour that constraint, or does it
restate it and then trust the first read anyway? A constraint that only appears in the report's
preamble is not being followed.

Second thing to watch: it ranked well within issues but had to be *asked* for the cross-issue
map. If a future run still buries collisions and phantom dependencies below per-issue findings,
make the two axes separate required output sections rather than one ranked list.
