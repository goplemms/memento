# memento in Claude Projects

A Claude Project runs many cloud threads in parallel, each in its own container
that is thrown away when the thread goes idle. Three things in the plugin adapt
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
re-injects the active feature's "Current block" on resume and after compaction.
Project threads start above the repo clones, so outside a repo it reads every
repo's workspaces in the shared folder.

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
(a session and what happened in it). Write the report to
/mnt/project-files/memento/skills-mining/<yyyy-mm-dd>.md when that folder
exists, otherwise publish it as a private artifact. Do not edit the repository
or open pull requests.
```
