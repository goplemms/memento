# Example: Decompose to Issues

*One instance of the skill — inheriting a 26-issue backlog written before any implementation
existed, reviewing it against the code, then re-cutting it along a phase boundary. The shape
here is: verify the premise, audit within and between, split by phase, sequence.*

## Context

A stock-screener repo with a scaffolded monorepo (FastAPI + React + a DuckDB/Parquet lake)
and 26 open issues forming the backlog. The issues were detailed and confident — most cited
specific files and line-level behaviour. Nothing of the product was built. The ask was an
execution plan; the real work turned out to be establishing which of the backlog's claims
were still true.

## Prompt

Follow `skills/decompose-to-issues/SKILL.md`.

The backlog was written before implementation, so some of it will be wrong. Verify claims
against the code rather than trusting the issue text — several cite specific files, so check
a sample of those citations are still accurate. Then re-cut it so the UI work can proceed
against mocks while the backend lands behind a frozen contract.

## Expected Shape

**The premise check outranked everything.** `main` was a single commit containing a one-line
`README.md`. The entire scaffold — and the `CLAUDE.md` whose architecture rules every issue
cited — lived on an unmerged branch with no open PR. All 26 issues referenced paths that did
not exist on the default branch. That became issue zero; nothing else was startable without it.

**Within-issue findings, each verified against the code:**

- Three issues carried a "concrete bug to fix here" that was *already fixed* — a Pydantic
  request model missing `extra="forbid"`, a `Number(null) → 0` coercion in a cell renderer,
  and an env-var prefix divergence. All three were closed by two commits that landed after
  the issues were written. An implementer would have opened each file expecting a bug.
- A systematic stale cross-reference: two architecture rules had been *inserted* into
  `CLAUDE.md` after most issues were written, shifting every rule number below them. Ten
  issues cited "rule 3 — the ingest pipeline is the single writer" and similar. The quoted
  text was right; the number pointed at a different rule entirely.
- Acceptance criteria that could not be met as written: a 5-working-day spike demanding
  live-API evidence *and* five answered licence questions across seven vendors, while its own
  Risks section conceded licence terms get decided by sales conversations. Restructured into
  a 2-day desk screen across all seven plus 5 days against a shortlist of three, with
  `PENDING` as a legitimate cell value.

**Between-issue findings — the ones invisible from inside any single issue:**

- **Duplicate ownership, twice.** An auth-bypass startup guard was fully specified in two
  issues; a server-free OpenAPI dump was claimed by two more. Assigned one owner each, cut
  from the other.
- **A phantom dependency.** The repo's own sequencing doc ordered a small coordination issue
  *after* a large design issue. Their files were disjoint — one touched `models.py`, the other
  `docs/`, `sql/` and `storage.py`. They could run concurrently, and the coordination issue's
  entire value was landing first.
- **A gap nothing covered.** The provider Protocol had exactly two methods, `fetch_symbols`
  and `fetch_daily_bars`. A grep found zero occurrences of `fundamental`, `corporate_action`
  or `knowledge_date` anywhere in source — yet three issues consumed fundamentals and one
  designed a schema for them. **Nothing ingested them.** Found by asking "where does this
  input come from?", not by reading titles.
- **A collision map.** Four issues each had to edit one domain model file; two both claimed
  ownership of a URL-serializer module *and* both listed "delete the placeholder block" as an
  acceptance criterion; three edited one CI workflow. Single owners and an order assigned.

**The phase re-cut.** With the UI prioritised, the seam was "needs a real backend or real
data". Rather than adding a "mock scope" section to each issue body — which reads as one
ticket regardless — three child issues were created carrying the closeable slice, linked as
real tracker sub-issues, labelled `scope:mock`, with parents relabelled `scope:real-data` and
commented with exactly what remained. The split was lopsided in a useful way: most of each
feature turned out to be mock-satisfiable, and only `total_matched` over a real partition,
saved-screen persistence, and the PKCE flow genuinely needed the real thing.

## Notes

**The retraction is the most useful thing in this example.** A reported finding —
"placeholder text like `providers/<vendor>.py` has been stripped from these issue bodies" —
was wrong. The tracker's *read* API silently drops unrecognised tag-like sequences, so the
stored text was fine and only the rendering was damaged. It was caught when a different API
call echoed the same bodies back raw with the placeholders present and no write in between.

By then the bad finding had produced edits to an issue body and six correction comments, all
of which had to be publicly retracted. Cost far more than the imaginary defect would have.

The rule that came out of it, now in both assets: **confirm through a second path before
reporting a finding that rests on tool output.** Especially findings of the form "this is
missing" — absence is exactly what a sanitising read path manufactures.

Two smaller things worth keeping:

- **Verify quantities, not just prose.** "Two hardcoded rows" was three; "a ~85-line
  component" was 86. Cheap to check, and being wrong reliably indicated the surrounding
  paragraph was written from memory rather than from the file.
- **Run the tooling before trusting the issue that describes it.** `uv sync --locked`,
  `pytest`, `mypy` and `pnpm -r typecheck` were all executed. Three of them confirmed issue
  claims; the fourth reproduced a documented failure with exact line numbers the issue had
  described only in prose — which made the issue better, not just verified.
