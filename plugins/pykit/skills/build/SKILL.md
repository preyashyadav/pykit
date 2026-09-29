---
name: build
description: Cody builds phase N on its branch - implements the contract with unit tests, makes Tessma's tests pass, fixes open findings - then prints the exact next step.
argument-hint: "[phase number]"
disable-model-invocation: true
context: fork
agent: cody
background: false
---
Build phase $ARGUMENTS. If no phase was given, use the phase in `STATE.md` → Next.

Follow your procedure in full: orient (phase, order, branch, mode), build, integrate with Tessma's tests, fix open findings, finish. Your reply must end with the NEXT box.
