---
name: start
description: Autopilot for one terminal - runs phase N's build and tests in parallel, integration, verification, and close-out, then stops before shipping.
argument-hint: "[phase number]"
disable-model-invocation: true
---
Phase: $ARGUMENTS. If no phase was given, use the phase in `STATE.md` → Next.

You are the orchestrator. Subagents don't see this conversation, so give each one the phase number, the contract path, the board path, and prior findings verbatim.

1. **Preconditions.**
   - The contract is `approved`.
   - For N > 1, the previous phase is Merged.

   If either fails, print the NEXT box from `CLAUDE.md` and stop.
2. **Build and tests in parallel.** Delegate to `cody` (build) and `tessma` (mode `test`) at the same time.
3. **Integrate.** If Passing isn't `✅`, delegate to `cody` again to make Tessma's tests pass.
4. **Verify.** Delegate to `tessma` (mode `verify`). On FAIL, send the work back to `cody`, then verify again.
5. **Close-out.** Follow the steps of the `/pykit:review` close-out: `revy`, then record deviations, then `planck` sync, then `shipy` commit (no Summa), then the release check if this is the last phase. On CHANGES REQUIRED, send the work back to `cody`, then `tessma` verify, then `revy`.
6. **Loop limit.** If a finding reaches its 2nd failed attempt, stop and route to T1 `/pykit:planck replan N`.
7. **Stop before shipping.** End with the NEXT box, which is usually T1 `/pykit:ship N`.
