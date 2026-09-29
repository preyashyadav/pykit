---
name: review
description: Independent read-only code review of a phase diff by Revy - correctness, security, contracts, acceptance coverage. Returns PASS or CHANGES REQUIRED with evidence.
argument-hint: "[phase number | git ref]"
context: fork
agent: revy
background: false
---
Review: $ARGUMENTS

If this is a phase number, review that phase against `docs/phases/phase-NN.md` and its `Base ref:`. If it is a git ref, review `git diff <ref>` together with the current phase contract. If it is empty, review the current phase from `STATE.md`.

Return your verdict in the output format your instructions define.
