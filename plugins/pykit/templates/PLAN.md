# Plan

## Architecture
TBD

## Boundaries and data flow
TBD

## Interfaces / contracts
TBD

## Dependencies
TBD

## Risks
TBD

## Quality gates
Only commands that exist in this repository. Planck fills this in, and every agent runs it.

| Gate | Command |
|---|---|
| (none yet) | |

## Test layout and ownership
| Area | Owner | Path |
|---|---|---|
| Unit tests | Cody | TBD |
| Acceptance / integration / E2E tests | Tessma | TBD |
| Test tooling: runners, config, fixtures infra, dependencies | Cody (Tessma requests changes on the board) | TBD |
| Start app for tests | Cody creates | TBD (command, port, seed data) |

## Delivery
- Default branch: `main`
- One branch per phase: `phase/NN-<slug>`, created from an up-to-date `main` when the phase starts, and merged back before the next phase starts.
- Remote: TBD (`origin` present? PRs via `gh`?)

## Roadmap
| Phase | Goal | UI | Depends on |
|---|---|---|---|

## Release criteria (checked after the last phase)
- Every phase is merged, and the full test suite and all quality gates pass on the release branch.
- Every acceptance criterion in SPEC.md has passing evidence.

## Definition of done (every phase)
- Quality gates pass, Tessma's tests pass, Tessma verify PASS, Revy PASS, report written, phase committed and merged.
