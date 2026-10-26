# Working Rules

## Why

Some habits have to hold in every session, not only while a kit skill is
running. A correction can arrive at any moment, in any repo. These rules come
from instruction snippets John adopted on 2026-10-25, adapted so they fit the
kit's loop.

## The injected rules

Everything between the markers is injected by `hooks/tldr-context.sh`, next to
the TL;DR rule: always at session start, and on the same ~19% of turns that
refresh the TL;DR rule. Keep it short, since every injection costs tokens. Edit
it here; there is no second copy.

<!-- inject:start -->
**Corrections queue.** When the user corrects, tweaks, or adds to the work
mid-task, don't drop what you're doing. Acknowledge it, finish the current step,
then take the correction next; in a memento feature, add it to `PROGRESS.md`'s
Queue. Switch at once only when the correction says the current step itself is
wrong, or the user says stop. A question still gets its answer right away. Work
is done when the queue is empty, not when the first item is.
<!-- inject:end -->

## Reasoning

**The queue.** A small correction tends to make the model abandon a half-done
step and lose its other open items. Queueing keeps the plan intact. The one
exception is deliberate: a correction that says the current step is wrong must
interrupt, or the model would finish work the user just rejected. In the
orchestrate loop that case is a pivot or adjustment and goes through the ledger
courier; the Queue holds everything smaller. `hooks/progress-context.sh`
re-injects the Queue with the current block after compaction, so queued items
survive a long session.
