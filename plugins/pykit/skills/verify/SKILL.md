---
name: verify
description: Tessma verifies built phase N - gates, full suite, test integrity, real-app and browser checks - and returns PASS or FAIL with V# findings, then prints the exact next step.
argument-hint: "[phase number]"
disable-model-invocation: true
context: fork
agent: tessma
background: false
---
Mode: `verify`. Phase: $ARGUMENTS. If no phase was given, use the phase in `STATE.md` → Next.

Follow your `verify` mode in full. Record findings on the board and set the Verified cell. Your reply must end with the NEXT box.
