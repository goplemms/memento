# Ideas ledger

One line per idea, across every repo in the project, so nothing lives only in a
dated brainstorm or an archived `PROGRESS.md`. `bin/ideas-ledger.sh` prints
where this file lives and creates it from the kit's template.

**Who writes it.**

- A brainstorm or ideation adds its ideas as `open` rows (the write-up stays
  where it is; the row points at it in **Source**).
- `memento:land` adds Kit gaps and reflection follow-ups the feature didn't
  fix as `open` rows, and marks the feature's own row `shipped` with a
  **Did it fire?** line.
- The weekly pulse updates **Status** and **Did it fire?** from what it sees in
  sessions, and reads this file instead of re-reading old brainstorms.

**Status.** `open` · `picked: <thread>` · `shipped: <PR, or what shipped it
when it wasn't a PR>` · `dropped: <why>`. A short note in parentheses may
follow, such as who it waits on. Edit the row in place; never delete one.

**Did it fire?** Only for `shipped` rows. Name what a real session would show
if the change works (`look for: <what>`), then one state: `unchecked` until
the first check, `not yet (<date checked>)`, `seen <date>: <session or thread>`, or
`never: <why>` once four weeks of sessions that should have shown it show
nothing. A `never` row is a new problem: add an `open` row for it. A change
with nothing a session could show (a removal) gets `n/a: <why>`.

**Effort.** `S` a line or a setting · `M` a small PR · `L` a new skill or more.

| ID | Idea | Source | Effort | Status | Did it fire? |
|----|------|--------|--------|--------|--------------|
