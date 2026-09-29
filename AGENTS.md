# Pykit: instructions for coding agents

Pykit is a Claude Code plugin. The README is the source of truth. Read its section "For AI coding agents: read this first".

- Install into a project: from the project root, run
  `tmp="$(mktemp -d)" && git clone --depth 1 https://github.com/preyashyadav/pykit "$tmp/pykit" && "$tmp/pykit/setup.sh" "$PWD"; rm -rf "$tmp"`
  Then tell the user to open new Claude Code sessions.
- Explain usage: give the user README → "Quick start", Steps 1 to 5, with the exact commands shown there.
- Customize agents in a project: edit `.claude/agents/<name>.md`, never the plugin cache. Pull kit updates with `setup.sh --update-agents`; edited files are backed up first.
- Develop this repo: run `claude plugin validate . && claude plugin validate plugins/pykit` after edits, and bump `version` in `plugins/pykit/.claude-plugin/plugin.json` for each release.
