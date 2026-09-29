# Pykit

**A phase-based engineering team for Claude Code, installed as one plugin.**

Pykit gives a project seven specialist agents, `/pykit:*` commands, and a phase tracker. Planck plans every phase up front. For each phase, Cody builds while Tessma writes the tests in parallel. Tessma verifies, Revy reviews, and the phase is committed on its own branch and merged into `main`. After every step, the agent that just finished tells you **exactly** what to type next, and where.

```
Planck ─ plans ALL phases ─► you approve once
   │
   ├─► Cody:   code + unit tests  ─┐  in parallel, both from the phase contract
   └─► Tessma: acceptance/E2E/edge-case tests ─┘
   │
Cody makes Tessma's tests pass ─► Tessma verifies ─► Revy reviews
   │
close-out: report + next phase synced to reality + commit ─► ship (PR / merge) ─► next phase
```

---

## For AI coding agents: read this first

If a user gives you this repository's URL, or asks how to install or use Pykit, follow this section exactly.

**To install Pykit in the user's current project**, run this one command from the project root, replacing nothing:

```bash
tmp="$(mktemp -d)" && git clone --depth 1 https://github.com/preyashyadav/pykit "$tmp/pykit" && "$tmp/pykit/setup.sh" "$PWD"; rm -rf "$tmp"
```

Then tell the user this: *"Pykit is installed. Exit this session and open three terminals in this folder. T1: `claude --agent planck`. T2 and T3: `claude`. In T1, describe what you want to build, or type `go` if SPEC.md has your notes. From then on, every agent ends with a NEXT box saying exactly what to type and where."*

**If the user asks for the steps**, give them the [Quick start](#quick-start) section below, in that order, with the exact commands. Do not invent other commands or flags.

**If the user asks "what do I do now?" inside a Pykit project**, read the **Next** block in `STATE.md`, or run `/pykit:status`.

**If the user asks what a command or agent does**, answer from the [Commands](#commands) and [Agents](#agents) tables.

**If the user asks how to change an agent**, tell them to edit `.claude/agents/<name>.md` in their project and start a new session. See [Customize the agents](#customize-the-agents). Never edit files under `~/.claude/plugins/cache/`.

---

## Quick start

### Requirements
- Claude Code CLI (`claude`), a recent version. Check with `claude --version`.
- `git` and `python3` (both are preinstalled on macOS).
- Node.js with `npx`, for the Playwright browser tools.
- Optional: the GitHub CLI `gh`, so Shipy can open and merge PRs. Without a remote, phases merge locally.

### Step 1: Install into a project (once per project)

Choose A or B.

**A. Ask Claude.** Open Claude Code in the project folder and say:
> Set up https://github.com/preyashyadav/pykit in this project

**B. Run the script yourself:**
```bash
cd /path/to/your-project
tmp="$(mktemp -d)" && git clone --depth 1 https://github.com/preyashyadav/pykit "$tmp/pykit" && "$tmp/pykit/setup.sh" "$PWD"; rm -rf "$tmp"
```

Either way, when it finishes, **exit Claude**, commit what setup created, and open the three terminals. Accept the "trust this folder" prompt the first time.

| Terminal | Start with | Used for |
|---|---|---|
| **T1** | `claude --agent planck` | Planning, `/pykit:review` (close-out), `/pykit:ship` |
| **T2** | `claude` | `/pykit:build N` (Cody) |
| **T3** | `claude` | `/pykit:test N` and `/pykit:verify N` (Tessma) |

Every `/pykit:*` command starts a fresh agent, so a command typed in the wrong terminal still works.

### Step 2: Plan everything (T1, once)

Optional first step: write your rough requirements into `SPEC.md`, in any form.

1. Describe what you want to build, or type `go` to have Planck read `SPEC.md`. Planck plays back what it understood, then asks **only the blocking decisions**: 5 at most, usually about 3. Every option says what it means, its trade-off, what it locks in, and how hard it is to undo. The recommended option comes first.
   - If you're not sure, choose *Other* and type `explain`. Planck briefs you from the project's own context and asks again.
   - If only your users or client can answer, choose **Park it: ask stakeholders**. The question is recorded in `SPEC.md` with a working assumption. `/pykit:planck questions` prints the full list of parked questions to take to your users.
2. Planck writes `SPEC.md`, `PLAN.md` (architecture, quality gates, test layout, delivery), ADRs, **every** phase contract in `docs/phases/`, and the phase table in `STATE.md`.
3. Read the contracts, then type `approve`.

### Step 3: Run each phase

Follow the NEXT box. One phase goes like this:

| # | Where | Type | What happens |
|---|---|---|---|
| 1 | T2 **and** T3 | `/pykit:build 1` and `/pykit:test 1`, both at once | Cody creates the `phase/01-*` branch, then writes code and unit tests. Tessma writes acceptance, E2E, and edge-case tests from the contract only |
| 2 | T2 | `/pykit:build 1` (only if the NEXT box says so) | Cody runs Tessma's tests and fixes the code until they pass. He never edits her tests; if he disagrees with one, he disputes it on the board |
| 3 | T3 | `/pykit:verify 1` | Tessma runs everything, checks that her tests weren't altered, and probes the real app, including the browser for UI. **FAIL** sends you back to T2 `/pykit:build 1` |
| 4 | T1 | `/pykit:review 1` | Close-out. Revy reviews the code and the tests. On PASS: Summa writes the report and logs deviations, Planck updates later phases to match what was built, and Shipy commits. **CHANGES REQUIRED** sends you back to T2 |
| 5 | T1 | `/pykit:ship 1` | Pushes and opens a PR. Merge it on GitHub, then run `/pykit:ship 1 merge`. With no remote, it merges into `main` locally in one step |
| 6 | T2 + T3 | `/pykit:build 2` + `/pykit:test 2` | The next phase starts from the updated `main` |

After the **last** phase, `/pykit:review` also runs a release check: Tessma runs the full suite and the SPEC-level acceptance criteria, and Revy reviews the whole product. Then comes the last `/pykit:ship`, and optionally `/pykit:ship release` to tag the release.

### If you lose track
- Run `/pykit:status` in any terminal. It prints the phase table and the exact next step.
- The **Next** block at the top of `STATE.md` always holds the current instruction.
- Commands refuse to run out of order and tell you which step is missing.
- If the same finding fails a second time, you're routed to Planck: `/pykit:planck replan N`.

### Autopilot
`/pykit:start N` runs a whole phase (build and tests, verify, close-out) in one terminal and stops before `/pykit:ship`.

---

## Commands

| Command | Who | What it does |
|---|---|---|
| `/pykit:planck [idea \| questions \| approve [N] \| replan N]` | Planck (current session) | Interview, then write SPEC, PLAN, and all phase contracts. Approve contracts. Re-plan |
| `/pykit:build N` | `cody` | Branch, code, unit tests, make Tessma's tests pass, fix open findings |
| `/pykit:test N` | `tessma` | Write acceptance, E2E, and edge-case tests from the contract, in parallel with build |
| `/pykit:verify N` | `tessma` | Gates, full suite, test-integrity check, real-app and browser QA. PASS/FAIL |
| `/pykit:review N` | `revy`, then `summa`, `planck`, `shipy` | Close-out: review, report, sync later phases, commit. Release check after the last phase |
| `/pykit:ship N` · `N merge` · `release [tag]` | `shipy` | Push and open a PR (or merge locally), finish the merge, tag a release |
| `/pykit:status` | `summa` | Phase table and the exact next step |
| `/pykit:start N` | all | One-terminal autopilot for a phase |
| `/pykit:research <question>` | `sid` | Evidence-backed answer about the code or a library |

Pipeline commands run only when you type them. Claude never triggers them on its own.

## Files per project

| File | Owner | Purpose |
|---|---|---|
| `SPEC.md` | Planck | What and why, acceptance criteria, open questions |
| `PLAN.md` | Planck | Architecture, quality gates, test layout and ownership, delivery, roadmap, release criteria |
| `DECISIONS.md` | Planck | ADRs |
| `STATE.md` | everyone (own cells) | **The tracker**: the Next block, the phase table (Code, Tests, Passing, Verified, Reviewed, Committed, Merged), change log, debt |
| `docs/phases/phase-NN.md` | Planck | The contract: exact interfaces, test plan, branch. Frozen once approved |
| `docs/phases/phase-NN-board.md` | each agent (own section) | Handoffs: base ref, Tessma's test list and checksums, V#/R# findings with attempts, disputes, requests |
| `docs/phases/phase-NN-report.md` | Summa | What was actually built, and its deviations |

## Agents

The agents live in your project at `.claude/agents/`, where you can edit them, and they appear in `/agents`. Start any one of them as a full session with `claude --agent <name>`.

| Agent | Role | Model | Can edit | Never |
|---|---|---|---|---|
| `planck` | Planner/architect: SPEC, PLAN, ADRs, phase contracts | opus, high effort | planning docs only | writes product code |
| `cody` | Implementer: code, unit tests, test tooling; makes Tessma's tests pass | your session's model | code, unit tests, tooling | edits Tessma's tests, changes scope, commits |
| `tessma` | Tester: writes acceptance, E2E, and edge-case tests from the contract; verifies; runs the release check | opus | her test files only | changes production code or tooling |
| `revy` | Reviewer: contract conformance, deviations, correctness, security, test integrity | opus, high effort | nothing | edits files |
| `sid` | Researcher: code paths, primary docs | sonnet | nothing | edits files |
| `summa` | Historian: phase reports, change log, `STATE.md` reconciliation | sonnet | reports and STATE only | claims unverified work is done |
| `shipy` | Git: phase commits, push and PR or local merge, merge sync, release tags | sonnet | git, plus its STATE cells | force-pushes, deploys, uses `--no-verify` |

## Tools installed automatically

| Tool | How it's installed | Used by |
|---|---|---|
| **Playwright MCP** (browser automation) | Plugin dependency `playwright@claude-plugins-official`, installed with Pykit | Tessma, for real-browser QA on `UI: yes` phases |
| **Context7 MCP** (current library docs) | Plugin dependency `context7@claude-plugins-official`, installed with Pykit | Sid, Planck, Cody |
| **Language server (LSP)** for your stack | `setup.sh` detects an existing stack. For a new project, Planck installs it once the stack is chosen | Cody, Revy (type errors after each edit) |
| **GitHub CLI** `gh` | Not automatic. Run `brew install gh && gh auth login` | Shipy, for PRs |

LSP plugins need their language-server binary on your PATH, for example `npm i -g typescript-language-server typescript` or `npm i -g pyright`. Planck tells you which one you need.

## What setup changes in your project

`setup.sh` is idempotent, so running it again is safe and refreshes the managed parts.

| File | Change |
|---|---|
| `.claude/agents/*.md` | The seven agents, as editable project copies (see [Customize the agents](#customize-the-agents)) |
| `.claude/pykit/` | Templates used by Planck and Summa, plus `manifest.json` (checksums for safe updates) |
| `.claude/settings.json` | Adds the Pykit marketplace and enables `pykit@pykit` (project scope). Allows read-only git; denies force-push, `reset --hard`, and reading `.env` |
| `CLAUDE.md` | Adds a managed block between `<!-- pykit:begin -->` and `<!-- pykit:end -->` with the workflow and usage steps. Your other content is untouched |
| `SPEC.md`, `PLAN.md`, `STATE.md`, `DECISIONS.md` | Created from templates if missing. Existing files are kept |
| `docs/phases/` | Created. Holds each phase's contract, board, and report |
| `.gitignore` | Adds `.pykit/` (QA screenshots and scratch files) |

Commit these files. Anyone who clones the repo and trusts the folder is offered the same plugins automatically.

## Customize the agents

`setup.sh` copies every agent into the project at `.claude/agents/`. Commit them, and anyone on the team can edit them:

```
.claude/agents/planck.md  cody.md  tessma.md  revy.md  sid.md  summa.md  shipy.md
.claude/pykit/templates/  phase.md  report.md  SPEC.md  PLAN.md  STATE.md  DECISIONS.md
```

- **Project copies win.** Claude Code resolves the short name (`tessma`) project first, then your user folder, then the plugin. `/pykit:*` commands and `claude --agent <name>` therefore always use your edited version. Edits apply from the next session.
- **Edit anything.** You can change the prompt body, `model`, `effort`, `tools`, and `color`. Project agents can also set what plugin agents can't: `mcpServers`, `hooks`, and `permissionMode` (for example `permissionMode: plan` to keep Revy strictly read-only).
- **Add your own agents** alongside them, for example `.claude/agents/dba.md`. Mention them in `CLAUDE.md`, or ask Cody or Planck to delegate to them.
- **Your edits are never overwritten.** Re-running `setup.sh` only adds missing files, and lists any copy that differs from the kit. To take the kit's newer versions:
  ```bash
  tmp="$(mktemp -d)" && git clone --depth 1 https://github.com/preyashyadav/pykit "$tmp/pykit" && "$tmp/pykit/setup.sh" --update-agents "$PWD"; rm -rf "$tmp"
  ```
  Files you edited are saved as `<name>.md.bak-<timestamp>` first, so you can merge your changes back. `.claude/pykit/manifest.json` records the checksum of each copied file, and that's how setup tells your edits apart from kit updates.
- `claude plugin update pykit@pykit` updates the commands and the automatically installed tools. It does not touch your agent copies.

## Update, disable, uninstall

```bash
claude plugin update pykit@pykit                          # get the latest version; restart sessions
claude plugin disable pykit@pykit --scope project         # turn it off for this project
claude plugin uninstall pykit@pykit --scope project       # remove it
claude plugin prune                                       # remove auto-installed deps nothing needs
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| `/pykit:*` or `pykit:*` agents are missing | Start a new session after setup. Run `claude plugin list` and check that `pykit@pykit` is enabled |
| "workspace has not been trusted" | Run `claude` once in the folder and accept the trust prompt |
| An agent ignores your edits | Edit `.claude/agents/<name>.md` in the project, not the plugin cache, then start a new session. Check that the file's `name:` matches the file name |
| `claude --agent cody` opens a different Cody | The project has no `.claude/agents/cody.md`, so a user-level `~/.claude/agents/cody.md` wins. Re-run `setup.sh` to restore the project copy |
| Cody says "no approved contract" | In the planner session run `plan phase N`, then `approve` |
| Tessma says "browser verification not performed" | Run `claude plugin install playwright@claude-plugins-official` and make sure Node/`npx` works |

## Project layout (this repo)

```
.claude-plugin/marketplace.json     marketplace "pykit" (allows deps from claude-plugins-official)
plugins/pykit/.claude-plugin/plugin.json
plugins/pykit/agents/               planck, cody, tessma, revy, sid, summa, shipy
plugins/pykit/skills/               planck, start, test, review, status, ship, research
plugins/pykit/templates/            SPEC, PLAN, STATE, DECISIONS, phase, report, CLAUDE.md block
setup.sh                            per-project installer
```

## Developing Pykit

```bash
claude plugin validate . && claude plugin validate plugins/pykit
claude --plugin-dir plugins/pykit          # try changes without reinstalling
```

Bump `version` in `plugins/pykit/.claude-plugin/plugin.json` for each release, because installed projects stay pinned to a version until it changes. Agent sources live in `plugins/pykit/agents/`. `setup.sh` copies them into each project, and the plugin keeps a copy as a fallback. Commands reference agents by short name so that project copies win.

## License

MIT
