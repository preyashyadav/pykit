---
name: ship
description: Ship a closed phase with Shipy - push and open a PR (or merge locally when there is no remote); `/pykit:ship N merge` finishes a merged PR back into main; `/pykit:ship release [tag]` tags the release. Prints the exact next step.
argument-hint: "plan | N | N merge | release [tag]"
disable-model-invocation: true
context: fork
agent: shipy
background: false
---
Request: $ARGUMENTS

Choose the mode:
- `plan` → `plan` (commit the approved planning docs on the default branch)
- `N` alone → `ship`
- `N merge` → `merge`
- `release [tag]` → `release`
- no phase number → the phase in `STATE.md` → Next, in `ship` mode

The user has authorized this git action by running the command. Your reply must end with the NEXT box.
