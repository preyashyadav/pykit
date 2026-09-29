---
name: test
description: Tessma writes phase N's acceptance, E2E, and edge-case tests from the contract alone (run in parallel with /pykit:build), then prints the exact next step.
argument-hint: "[phase number]"
disable-model-invocation: true
context: fork
agent: tessma
background: false
---
Mode: `test`. Phase: $ARGUMENTS. If no phase was given, use the phase in `STATE.md` → Next.

Follow your `test` mode in full. Your reply must end with the NEXT box.
