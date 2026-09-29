---
name: review
description: Close out phase N - Revy reviews code and tests; on PASS, Summa writes the report, Planck syncs later phases to what was built, Shipy commits; after the last phase, runs the release check. Prints the exact next step.
argument-hint: "[phase number]"
disable-model-invocation: true
---
Phase: $ARGUMENTS. If no phase was given, use the phase in `STATE.md` → Next.

You are the close-out orchestrator. You run the steps below; the specialists do the work. Subagents don't see this conversation, so give each one:
- the phase number;
- the contract path `docs/phases/phase-NN.md`;
- the board path `docs/phases/phase-NN-board.md`;
- the base ref from the board;
- any verdicts it needs, verbatim.

1. **Preconditions.** `STATE.md` shows Verified `✅` for phase N (not `♻` or `❌`). If it doesn't, print the NEXT box from the routing table in `CLAUDE.md` and stop.
2. **Review.** Delegate to the `revy` agent in `phase` mode, and record the result yourself:
   - Add each `R#` finding to the board's Findings table with status `open`. If it matches an earlier `R#` that was `fixed`, reopen that row and increment its Attempts.
   - Set Reviewed to `✅` (PASS) or `❌` (CHANGES REQUIRED).
   - If the verdict is CHANGES REQUIRED, stop and print the NEXT box: T2 `/pykit:build N`. If any finding has reached its 2nd failed attempt, the box routes to T1 `/pykit:planck replan N` instead.
3. **Report.** Delegate to the `summa` agent in report mode. Give it Tessma's verify verdict (from the board or `STATE.md`) and Revy's full output, including the deviations.
4. **Sync.** Delegate to the `planck` agent in sync mode. It updates the later contracts from the report and deviations. Note any contract that went back to `draft`.
5. **Commit.** Delegate to the `shipy` agent in `commit` mode. If it stops (a secret, stray files, a hook failure), report why and print the NEXT box.
6. **Release check.** Do this only if N is the last phase in `STATE.md`.
   1. Delegate to `tessma` in `release` mode and to `revy` in `release` mode, in parallel.
   2. Record `Release check: PASS` or `FAIL` in `STATE.md` → Waiting on you.
   3. On FAIL:
      - add the findings to phase N's board;
      - set Verified, Reviewed, and Committed to `♻`;
      - route to T2 `/pykit:build N`.

      The fix commits on the next close-out.
7. **Finish.** Summarize:
   - Revy's verdict and deviations;
   - the report path;
   - which later contracts changed, and which need re-approval;
   - the commit SHA;
   - the release result, if one ran.

   End with the NEXT box computed from the routing table in `CLAUDE.md`, and write the same box into `STATE.md` → Next. The usual next step is T1 `/pykit:ship N`. If a later contract went back to `draft`, the box must say so, because the user approves it in T1 after shipping.
