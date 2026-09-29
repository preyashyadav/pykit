---
name: review
description: Close out phase N - Revy reviews code and tests; on PASS, the deviations are recorded, Planck syncs later phases to what was built, and Shipy commits; after the last phase, the release check runs. Resumable; runs every step in the foreground. Prints the exact next step.
argument-hint: "[phase number]"
disable-model-invocation: true
---
Phase: $ARGUMENTS. If no phase was given, use the phase in `STATE.md` → Next.

You are the close-out orchestrator. You run the steps below; the specialists do the work.

**Run every delegation in the foreground and wait for it to finish.** Never background a subagent here, and never print a NEXT box before the last step finishes. The user must not act while the close-out is still running.

Subagents don't see this conversation, so give each one:
- the phase number;
- the contract path `docs/phases/phase-NN.md`;
- the board path `docs/phases/phase-NN-board.md`;
- the base ref from the board;
- the verdicts or deviations it needs, verbatim.

**Resume:** the board has a `## Close-out` checklist. Create it if it's missing:
```
- [ ] Review (Revy)
- [ ] Deviations recorded
- [ ] Sync (Planck)
- [ ] Commit (Shipy)
- [ ] Release check (last phase only)
```
Skip every step that is already ticked. The one exception: if `STATE.md` shows Reviewed as `♻` or not `✅`, untick all the steps and start over, because the code changed. Tick each step as soon as it succeeds. If a tool call fails because of the environment (for example, the permission classifier gave no verdict), stop at that step. Say which step to resume from, and route the NEXT box to the same `/pykit:review N`.

1. **Preconditions.** `STATE.md` shows Verified `✅` for phase N (not `♻` or `❌`). If it doesn't, print the NEXT box from the routing table in `CLAUDE.md` and stop.
2. **Review.** Delegate to the `revy` agent in `phase` mode. Then record:
   - each `R#` finding on the board with status `open` (if it matches an earlier `R#` that was `fixed`, reopen that row and increment its Attempts);
   - Reviewed as `✅` (PASS) or `❌` (CHANGES REQUIRED).

   On CHANGES REQUIRED, stop with the NEXT box: T2 `/pykit:build N`, or T1 `/pykit:planck replan N` if a finding has reached its 2nd failed attempt.
3. **Record deviations.** Write Revy's deviation list:
   - under `## Deviations (Revy)` on the board;
   - as one line per deviation in `STATE.md` → Change log, newest first, as `Phase NN: <what changed> → affects <later phase or area>`.

   Don't invoke Summa. It runs only when the user asks (`/pykit:report N`, `/pykit:status`).
4. **Sync.** Delegate to the `planck` agent in sync mode, with the deviation list and Revy's open MEDIUM and LOW findings. Note which contracts changed, which went back to `draft`, and **every finding carried into a later contract**.
5. **Commit.** Delegate to the `shipy` agent in `commit` mode. If it stops (a secret, stray files, a hook failure), report why and stop.
6. **Release check.** Do this only if N is the last phase in `STATE.md`.
   1. Delegate to `tessma` in `release` mode, then to `revy` in `release` mode.
   2. Record `Release check: PASS` or `FAIL` in `STATE.md` → Waiting on you.
   3. On FAIL:
      - add the findings to phase N's board;
      - set Verified, Reviewed, and Committed to `♻`;
      - untick Close-out;
      - route to T2 `/pykit:build N`.
7. **Finish.** Summarize:
   - Revy's verdict;
   - the deviations;
   - the later contracts that changed or went back to `draft`;
   - the findings carried into later phases;
   - the commit SHA;
   - the release result, if one ran.

   End with the NEXT box, and write the same box into `STATE.md` → Next. The usual next step is `→ T1: /pykit:ship N (Shipy pushes or merges)`. If a contract went back to `draft`, add a line to approve it in T1 after shipping.
