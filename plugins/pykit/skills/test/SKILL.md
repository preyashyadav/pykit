---
name: test
description: Independently verify a phase with Tessma - run the quality gates, audit tests against acceptance criteria, probe edge and failure cases, and exercise the real app (browser for UI phases). Returns PASS or FAIL.
argument-hint: "[phase number]"
context: fork
agent: tessma
background: false
---
Verify phase $ARGUMENTS. If no phase was given, use the current phase from `STATE.md`.

Follow your procedure in full. The contract is `docs/phases/phase-NN.md` (NN zero-padded). Return your verdict in the output format your instructions define.
