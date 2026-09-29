---
name: start
description: Run one approved phase end to end - preflight, implement (Cody), quality gates, verify (Tessma), review (Revy), report (Summa). Stops before committing and never starts the next phase.
argument-hint: "[phase number]"
disable-model-invocation: true
---
Phase: $ARGUMENTS

If no phase was given, use the current phase from `STATE.md`. If it can't be inferred, ask one question. NN below means the zero-padded phase number.

You are the orchestrator. The specialists do the work. Subagents don't see this conversation, so give each one the phase number, the contract path `docs/phases/phase-NN.md`, the base ref, and any previous findings verbatim.

1. **Preconditions.** Read the contract.
   - If it is missing, or its `Status` is not `approved`, stop and tell the user to run `/pykit:planck phase NN`.
   - Note its `Base ref:`.
   - Run `git status --porcelain`. If there are uncommitted changes unrelated to this phase, ask the user how to proceed before touching anything.
2. **Preflight.** Delegate to `planck` to reconcile the contract with repository reality. If it returns with the contract changed back to `draft`, or with blocking questions, show them to the user and stop.
3. **Implement.** If your own instructions say you are Cody, implement the phase yourself in this session. Otherwise, delegate to `cody`.
4. **Gates.** Run every command in PLAN.md → Quality gates yourself. If any fails, send the output to Cody to fix, then run the gates again.
5. **Verify.** Delegate to `tessma`. On FAIL, send the findings to Cody verbatim, then run the gates, then Tessma again.
6. **Review.** Delegate to `revy`. On CHANGES REQUIRED, Cody fixes the BLOCKER and HIGH findings, then run the gates, then Tessma again if behavior changed, then Revy.
7. **Loop limit.** If the same substantive failure comes back a second time, stop. Delegate to `planck` with the evidence and ask it to re-plan, then report to the user. Never make a third attempt at the same fix.
8. **Record.** Delegate to `summa` with both PASS verdicts verbatim. It writes `docs/phases/phase-NN-report.md` and updates `STATE.md`.
9. **Stop.** Do not commit (suggest `/pykit:ship`), and do not start the next phase.

In your final message, give:
- the Tessma and Revy verdicts;
- the last lines of gate output;
- a table mapping each criterion to its test;
- deviations;
- follow-ups;
- the next command.
