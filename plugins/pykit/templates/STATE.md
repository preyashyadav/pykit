# Project State

The tracker for every phase. Each agent updates only its own cells and the **Next** block. Summa keeps the other sections current.

## Next
<!-- Rewritten by every agent when it finishes. Exactly what the user should do next. -->
> **T1:** `claude --agent planck`, then describe what you want to build, or type `go` if SPEC.md already has your notes.

## Phases
| # | Phase | Contract | Branch | Code | Tests | Passing | Verified | Reviewed | Committed | Merged |
|---|---|---|---|---|---|---|---|---|---|---|

Legend: `—` not started · `⏳` in progress · `✅` done · `❌` failed (see board) · `♻` stale, needs re-run
- **Code**: Cody's implementation and unit tests
- **Tests**: Tessma's acceptance/E2E tests are written
- **Passing**: Cody has run Tessma's tests and they pass
- **Verified**: Tessma PASS · **Reviewed**: Revy PASS · **Committed**: phase commit on its branch · **Merged**: in `main`

## Change log
<!-- Deviations and decisions that later phases must know. Newest first. -->
- None yet.

## Technical debt
- None yet.

## Waiting on you
- None.
