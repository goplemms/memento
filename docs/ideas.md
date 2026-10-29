# Ideas as GitHub issues

## Why

Ideas used to live in dated brainstorm files, and lessons a feature didn't fix
sat in its archived `PROGRESS.md`. Nobody could see in one place what was open,
picked, shipped or dropped, and nothing checked whether a merged change ever
reached a real session. GitHub issues are where work is already tracked, so
every idea becomes one issue in the repo it belongs to, and a closed issue
stays watched until a session shows the change working.

## The scheme

Every idea is an issue labelled `idea`, in the repo whose code or settings it
changes (a kit asset → goplemms/memento). A repo that has never used the scheme
lacks the labels: create any that are missing before filing (`gh label
create idea`, or the repo's Labels page) rather than filing without them,
since the pulse finds issues by label.

| Status | On the issue |
|--------|--------------|
| open | open |
| picked | open, label `picked`, a comment naming the thread or session working it (orchestrate's Brief) |
| shipped | closed as completed, usually by the PR that ships it (`Closes #N` in the PR body), label `fire:watching` added before the merge |
| dropped | closed as not planned, with a comment saying why |

**Effort.** Label `effort:S` (a line or a setting), `effort:M` (a small PR) or
`effort:L` (a new skill or more).

**Did it fire?** A shipped issue's body has a **Did it fire?** section naming
what a real session would show if the change works. It carries one label:

- `fire:watching`: shipped, not yet seen. Each check adds a comment
  (`not yet, <date>: <what was checked>`).
- `fire:seen`: a comment names the session or workspace where it showed up.
- `fire:never`: four weeks of sessions that should have shown it showed
  nothing. The comment says why, and a new open `idea` issue tracks the
  failure.

A change with nothing a session could show (a removal) gets no `fire:` label;
say so in a comment.

## Who writes what

- **A brainstorm or ideation** files its ideas as open `idea` issues; the
  write-up stays where it is and the issue's **Source** links it.
- **`memento:orchestrate`** labels the issue a feature picks up `picked`.
- **`memento:ship`**, when it opens the PR, fills the issue's **Did it fire?**
  line, adds `fire:watching` and writes `Closes #N`, so the merge closes an
  issue that is already watched. It files the issue first when a
  behavior change has none.
- **`memento:land`** files every Kit gap, review finding and reflection
  follow-up the feature didn't fix, and checks the feature's own issue is
  closed and watched. Closeout's **Issues** line names them;
  `archive-feature.sh` refuses without it.
- **The weekly pulse** searches `label:"fire:watching"` issues, checks sessions
  for each one's sign and relabels them, and reads open `idea` issues for the
  status of earlier ideas.
- **Anyone dropping an idea** closes it as not planned with a comment saying why.

Search for a duplicate before filing (`is:issue label:idea <words>`); comment
on the existing issue instead of opening a second one.

## Issue body

```markdown
**Idea.** <one or two sentences: what changes and what it gets us>

**Source.** <brainstorm file and item, the feature or PR it came from, or the session>

**Did it fire?** <filled when it ships: look for <what a real session would show>>
```
