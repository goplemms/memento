# memento in Claude Projects

A Claude Project runs many cloud threads in parallel, each in its own container
that is thrown away when the thread goes idle. Four things in the plugin adapt
to that, and two pieces live in the project's settings because a plugin can't
ship them.

## What the plugin does on its own

**Feature workspaces live in the shared project folder.** `scratchpad/` is
gitignored and the checkout dies with the container, so a feature's `plan.md`
and `PROGRESS.md` would never reach the next thread. `bin/workspace-root.sh`
returns `/mnt/project-files/memento/<repo>/` when that folder exists and is
writable, and `new-feature.sh`, `archive-feature.sh` and `sweep-archive.sh` all
use it. Everywhere else (local sessions, plain web sessions, Remote Control) the
answer is still `scratchpad/`. Set `MEMENTO_WORKSPACE_ROOT` to force a location.

The shared folder keeps no history and the last write wins, so keep one feature
per thread. It is working state only: the durable record still graduates into
the repo at land time.

**The current milestone survives compaction.** `hooks/progress-context.sh`
re-injects the active feature's "Current block" and its Queue of waiting
corrections on resume and after compaction.
Project threads start above the repo clones, so outside a repo it reads every
repo's workspaces in the shared folder.

**One ideas ledger for the project.** Brainstorms, land's leftover lessons
and every shipped feature end up as one line each in
`/mnt/project-files/memento/ideas.md`, with a status (open, picked, shipped,
dropped) and, once shipped, a "did it fire?" note the weekly pulse checks
against real sessions. `bin/ideas-ledger.sh` prints the path and creates the
file from `templates/ideas.md`; outside a project it is `scratchpad/ideas.md`,
and `MEMENTO_IDEAS_LEDGER` forces a location. The header of the file says who
writes what. Like the workspaces, the last write wins, so re-read the file just
before editing a row.

**Decisions go on cards.** Project threads can post a tap-to-choose decision
card. The injected TL;DR rule tells any session that has one to ask the call
there, and orchestrate's commit gate, challenge's readout and land's
graduation step say the same. Sessions without the tool ask in text as before.

## What goes in project settings

### Project instructions

Paste this into Project settings → Instructions. It points every thread at the
workflow without repeating the skills.

```text
This project uses the memento plugin (github.com/goplemms/memento), installed
from main by the environment setup script. The first line of each session names
the loaded build.

- Drive features with memento:orchestrate. Feature workspaces live in
  /mnt/project-files/memento/<repo>/<feature>/. Before starting a feature,
  check there for an existing workspace and resume from its PROGRESS.md.
- One feature per thread. Don't edit another thread's workspace; ask that
  thread through the project chat instead.
- Never commit without the user's tap or word at the commit gate. Ask gates
  and other forks on a decision card.
- Open PRs as drafts; the thread that opened a PR drives it to green.
- At land, graduate the durable record into the repo, then archive the
  workspace with archive-feature.sh.
```

### Monthly skills-mining routine

The kit is meant to change with how it is used. This routine runs on the 1st
of each month, reads the last month of sessions, and writes a proposal to the
shared folder. It doesn't edit the repo or open PRs; a person picks what to
build. In a private project a routine can't start a fresh session, so create it
from a project thread and it fires back into that thread each month.

Prompt:

```text
Mine my Claude Code sessions from the last 30 days, across all repos, for how
the memento plugin (github.com/goplemms/memento) is actually used.

Keep it cheap: start from session titles and last-turn summaries, and open full
transcripts only for sessions that look relevant (kit skills used, feature
work, reviews, repeated asks). list_events returns the newest page first, so
page older events with before_id, and read a session's opening before judging
what it invoked.

0. Ideas ledger. Run the weekly ledger check below first, then start from
   what is open in the ledger rather than from old brainstorms.
1. Usage. For each skill, agent and hook: how often it fired or should have,
   where it helped, where sessions worked around it or repeated a procedure no
   skill covers.
2. Review gates. For each milestone commit: reviews the kit expected
   (implement's code-and-tests review, orchestrate's challenge, the
   discussion-to-plan red-team, the decompose-to-issues review gate), reviews
   that ran, review-gate refusals, "skipped: <why>" ledger rows, and findings
   acted on vs. dropped. Also read the PROGRESS.md Review ledgers in the shared
   folder. Name any review that never runs.
3. Reflections. Collect the one-line "what helped, what got in the way" notes
   that ship and land leave, grouped by kit asset.

Propose changes as add, modify, merge or remove, each with one line of evidence
(a session and what happened in it), and add each one to the ideas ledger.
Write the report to
/mnt/project-files/memento/skills-mining/<yyyy-mm-dd>.md when that folder
exists, otherwise publish it as a private artifact. Do not edit the repository
or open pull requests; the ideas ledger is the one file outside the report it
writes.
```

### Weekly ledger check

The "did it fire?" check needs a shorter beat than a month: a change that never
reaches a session should be caught within weeks. Put this in a routine that
runs weekly (in this project, the weekly pulse), or run it as the first step of
the monthly prompt above.

```text
Read the ideas ledger at /mnt/project-files/memento/ideas.md
(bin/ideas-ledger.sh prints the path; its header defines the statuses).
For each shipped row whose "Did it fire?" cell is unchecked or not yet, look
for its "look for:" sign in the sessions and workspaces since the merge, and
mark it "seen <date>: <where>" or "not yet (<date>)". Once four weeks of
sessions that should have shown it show nothing, mark it "never: <why>" and
add an open row for that failure. Add each new idea you find as an open row,
and update a row's Status when a thread picks it, a PR ships it, or it is
dropped. Re-read the file just before editing; edit rows in place and never
delete one. Report what changed in the ledger.
```
