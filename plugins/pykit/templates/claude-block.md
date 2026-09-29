<!-- pykit:begin (managed by pykit setup.sh; edits inside this block are overwritten) -->
## Pykit workflow

This project uses the Pykit plugin (https://github.com/preyashyadav/pykit). Control docs: `SPEC.md`, `PLAN.md`, `DECISIONS.md`, `STATE.md`, `docs/phases/`.

### How to use it (answer "how do I use pykit?" with these steps)
1. Plan in terminal 1: run `claude --agent planck` and describe the idea, or just say "go" to have it read SPEC.md. Planck interviews you, explaining every option and recommending one, then writes SPEC.md and PLAN.md. If you're unsure, answer "explain". Park questions only your users can answer, then run `/pykit:planck questions` to get a list to take to them.
2. In the same terminal, type `plan phase 1`, review the contract, then type `approve`.
3. Build in terminal 2: run `claude --agent cody`, then `/pykit:start 1`. This implements the phase, runs the gates, then Tessma tests, Revy reviews, and Summa writes the report.
4. Commit with `/pykit:ship 1`. Use `/pykit:ship 1 push pr` to also push and open a PR.
5. Check status at any time with `/pykit:status`. Then go back to step 2 with the next phase.

| Agent | Owns | Never |
|---|---|---|
| `planck` | SPEC, PLAN, DECISIONS, phase contracts | writes product code |
| `cody` | implementing the approved phase | changes scope, approves own work, commits |
| `tessma` | independent verification (Playwright for UI); may add tests | changes production code |
| `revy` | independent read-only review | edits files |
| `sid` | read-only research (Context7 for docs) | edits files |
| `summa` | phase reports, STATE.md | claims unverified work is done |
| `shipy` | commits (push on request) | force-pushes, deploys, discards work |

Agents live in `.claude/agents/`. Edit them to customize; project copies override the plugin. To pull kit updates, run `setup.sh --update-agents` (edited files are backed up first).

Other commands: `/pykit:planck [idea | questions | phase N | approve N | replan N]`, `/pykit:test N`, `/pykit:review N`, `/pykit:research <question>`.

### Rules
- Source of truth: the user's current instruction, then SPEC.md, accepted ADRs, the phase contract, PLAN.md, repo conventions.
- Build only phases whose contract says `Status: approved`. One phase at a time. Never start the next phase automatically.
- Quality gates are exactly the commands in PLAN.md → Quality gates. Never invent one.
- Done means: gates pass, Tessma PASS, Revy PASS, and the report is written.
- If the same failure happens twice, stop and re-plan with Planck.
- Record material changes as ADRs. Never rewrite old phase reports.
- No commit, push, or deploy unless the user asks. "Ship" means commit, not deploy.
<!-- pykit:end -->
