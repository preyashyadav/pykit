<!-- pykit:begin (managed by pykit setup.sh; edits inside this block are overwritten) -->
## Pykit workflow

This project uses the Pykit plugin (https://github.com/preyashyadav/pykit).
- Control docs: `SPEC.md`, `PLAN.md`, `DECISIONS.md`, and `STATE.md` (the tracker for all phases, with its **Next** block).
- Per phase: `docs/phases/phase-NN.md` (the contract), `phase-NN-board.md` (findings and handoffs), and `phase-NN-report.md`.
- Agents: `.claude/agents/`. Edit them to customize.

### Terminals
- **T1**: `claude --agent planck`. Planning, close-out, and shipping.
- **T2**: `claude`. Cody builds.
- **T3**: `claude`. Tessma writes tests and verifies.

Every `/pykit:*` command starts a fresh agent, so running one in the wrong terminal does no harm.

### Commands
| Command | Who | Does |
|---|---|---|
| `/pykit:planck` (or talk to Planck in T1) | Planck | Interview, then write SPEC, PLAN, and all phase contracts. `approve` approves them. `replan N` re-plans |
| `/pykit:build N` | Cody | Creates or joins the phase branch, writes code and unit tests, makes Tessma's tests pass, fixes open findings |
| `/pykit:test N` | Tessma | Writes acceptance, E2E, and edge-case tests from the contract only (in parallel with build) |
| `/pykit:verify N` | Tessma | Runs everything, probes edge cases, does browser QA. PASS or FAIL with V# findings |
| `/pykit:review N` | Revy, then Summa, Planck, Shipy | Close-out: review, then report, then sync the next phase, then commit. After the last phase, also runs the release check |
| `/pykit:ship N` | Shipy | Push and open a PR, or merge locally if there is no remote. `/pykit:ship N merge` finishes the merge |
| `/pykit:status` | Summa | Prints the tracker and the Next step |
| `/pykit:start N` | all | Autopilot: runs a whole phase in one terminal |
| `/pykit:research <q>` | Sid | Evidence-backed answer |

### Routing: every agent ends with a NEXT box computed from this table
Read `STATE.md` → Phases and the phase board. The first matching row wins. N is the current phase.

| # | Situation | NEXT |
|---|---|---|
| 1 | SPEC/PLAN not written, or phases not all written | T1: talk to Planck (`go`) |
| 2 | Some phase contracts are `draft` | T1: review `docs/phases/`, then type `approve` to Planck |
| 3 | A finding has failed its 2nd fix attempt, or a dispute needs a contract ruling | T1: `/pykit:planck replan N` |
| 3b | On the default branch, and approved plan files are uncommitted, or the repo has no commits | T1: `/pykit:ship plan` |
| 4 | Previous phase not Merged (for N>1) | T1: `/pykit:ship N-1` (or `/pykit:ship N-1 merge` if its PR is open) |
| 5 | Code and Tests both `—` | T2: `/pykit:build N` **and** T3: `/pykit:test N` (run both now) |
| 6 | Only one of Code or Tests is ✅, and the other is ⏳ or `—` | Wait for the other terminal. If it hasn't been started: T3: `/pykit:test N` or T2: `/pykit:build N` |
| 7 | Code ✅, Tests ✅, Passing not ✅, or open findings, or a stale `♻` tick | T2: `/pykit:build N` |
| 8 | Passing ✅, Verified not ✅ | T3: `/pykit:verify N` |
| 9 | Verified ✅, Reviewed not ✅ | T1: `/pykit:review N` |
| 10 | Reviewed ✅, Committed ✅, Merged not ✅ | T1: `/pykit:ship N` (then `/pykit:ship N merge` after the PR is approved) |
| 11 | Merged ✅ and a later phase exists | Move to phase N+1 and apply rows 2–10 |
| 12 | All phases Merged and the release check passed | Done. Optionally: T1: `/pykit:ship release` to tag it |

NEXT box format, written into `STATE.md` → Next and printed as the last lines of every reply. Each line names the terminal, the exact command, and in parentheses **the agents that command runs**. Never label a line with the terminal's session agent (for example "T1 (Planck)" for `/pykit:review`), because the user would think they should talk to that agent.
```
NEXT
→ T2: /pykit:build 2     (Cody builds)
→ T3: /pykit:test 2      (Tessma writes tests)   ← run both now
Why: phase 1 merged; phase 2 approved.
```
Close-out example: `→ T1: /pykit:review 1   (Revy reviews → Summa report → Planck sync → Shipy commit)`

### Rules
- Source of truth: the user's current instruction, then SPEC.md, accepted ADRs, the phase contract, PLAN.md, repo conventions.
- Contracts are frozen once approved. Changes go only through Planck (`replan`).
- Tessma owns acceptance, E2E, and edge-case tests. Cody owns code, unit tests, and test tooling. Cody never edits Tessma's test files; he disputes them on the board.
- Quality gates are exactly the commands in PLAN.md → Quality gates. Never invent one.
- One branch per phase (`phase/NN-<slug>`) from an up-to-date `main`, merged before the next phase starts. Never push, merge, or deploy except through `/pykit:ship`.
<!-- pykit:end -->
