---
name: ship
description: Commit a verified phase with Shipy (preconditions, secret scan, explicit staging, conventional commit). Pushes only if "push" is in the arguments.
argument-hint: "[phase number] [push] [pr]"
disable-model-invocation: true
context: fork
agent: shipy
background: false
---
Checkpoint request: $ARGUMENTS

If no phase number was given, use the current phase from `STATE.md`.

The user has authorized a commit. Push only if the word `push` appears in the request, and open a PR only if the word `pr` appears.
