---
name: report
description: On request only - Summa writes docs/phases/phase-NN-report.md for a reviewed phase (planned vs actual, deviations, follow-ups) and updates STATE.md's change log and debt.
argument-hint: "[phase number]"
disable-model-invocation: true
context: fork
agent: summa
background: false
---
Run in report mode for phase $ARGUMENTS. If no phase was given, use the latest phase whose Reviewed cell is `✅`.

Read the verdicts from the phase board and `STATE.md`. End with the NEXT box. Writing the report doesn't change the phase's routing.
