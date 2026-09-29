#!/usr/bin/env bash
set -euo pipefail

usage() { echo "usage: setup.sh [project-dir]   (env PYKIT_SOURCE=owner/repo|path overrides the marketplace source)" >&2; exit 1; }
[ $# -le 1 ] || usage
case "${1:-}" in -h|--help) usage ;; esac

kit="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project="$(cd "${1:-$PWD}" && pwd)"
tpl="$kit/plugins/pykit/templates"

command -v claude >/dev/null || { echo "claude CLI not found on PATH" >&2; exit 1; }
command -v python3 >/dev/null || { echo "python3 is required" >&2; exit 1; }

source="${PYKIT_SOURCE:-}"
if [ -z "$source" ]; then
  url=$(git -C "$kit" remote get-url origin 2>/dev/null || true)
  case "$url" in
    git@github.com:*|https://github.com/*)
      source=$(printf '%s' "$url" | sed -E 's#^(git@github.com:|https://github.com/)##; s#\.git$##') ;;
    "") source="$kit" ;;
    *) source="$url" ;;
  esac
fi

cd "$project"
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git init -q
  echo "initialized git repo in $project"
fi

echo "marketplace source: $source"
claude plugin validate "$kit"
if ! claude plugin marketplace list 2>/dev/null | grep -q 'claude-plugins-official'; then
  claude plugin marketplace add anthropics/claude-plugins-official
fi
claude plugin marketplace add "$source" --scope project
claude plugin install pykit@pykit --scope project

lsp=""
if [ -f tsconfig.json ] || [ -f package.json ]; then lsp=typescript-lsp
elif [ -f pyproject.toml ] || [ -f requirements.txt ] || [ -f setup.py ]; then lsp=pyright-lsp
elif [ -f go.mod ]; then lsp=gopls-lsp
elif [ -f Cargo.toml ]; then lsp=rust-analyzer-lsp
elif [ -f pom.xml ] || [ -f build.gradle ] || [ -f build.gradle.kts ]; then lsp=jdtls-lsp
fi
if [ -n "$lsp" ]; then
  claude plugin install "$lsp@claude-plugins-official" --scope project || echo "warning: could not install $lsp" >&2
else
  echo "no stack detected yet; Planck installs the language-server plugin once the stack is chosen"
fi

for f in SPEC.md PLAN.md STATE.md DECISIONS.md; do
  if [ -e "$f" ]; then
    echo "kept existing $f"
  else
    cp "$tpl/$f" "$f"
    echo "created $f"
  fi
done
mkdir -p docs/phases

python3 - "$tpl/claude-block.md" <<'PY'
import re, sys, pathlib
block = pathlib.Path(sys.argv[1]).read_text().rstrip() + "\n"
p = pathlib.Path("CLAUDE.md")
text = p.read_text() if p.exists() else ""
pattern = re.compile(r"<!-- pykit:begin.*?<!-- pykit:end -->\n?", re.S)
if pattern.search(text):
    text = pattern.sub(lambda _: block, text)
else:
    text = (text.rstrip() + "\n\n" if text.strip() else "") + block
p.write_text(text)
print("updated CLAUDE.md pykit block")
PY

python3 <<'PY'
import json, pathlib
p = pathlib.Path(".claude/settings.json")
data = json.loads(p.read_text()) if p.exists() else {}
perms = data.setdefault("permissions", {})
allow = ["Bash(git status*)", "Bash(git diff*)", "Bash(git log*)", "Bash(git show*)", "Bash(git rev-parse*)"]
deny = ["Bash(git push --force*)", "Bash(git push -f*)", "Bash(git reset --hard*)", "Read(./.env)", "Read(./.env.*)"]
for key, rules in (("allow", allow), ("deny", deny)):
    cur = perms.setdefault(key, [])
    cur.extend(r for r in rules if r not in cur)
p.parent.mkdir(exist_ok=True)
p.write_text(json.dumps(data, indent=2) + "\n")
print("merged permissions into .claude/settings.json")
PY

if ! grep -qxF '.pykit/' .gitignore 2>/dev/null; then
  printf '.pykit/\n' >> .gitignore
  echo "added .pykit/ to .gitignore"
fi

command -v gh >/dev/null || echo "optional: install the GitHub CLI so Shipy can open PRs: brew install gh && gh auth login"

cat <<EOF

Pykit is set up in $project
Installed: pykit (7 agents, /pykit:* commands) + playwright + context7${lsp:+ + $lsp}

Next: exit this session and start NEW ones (plugins load at startup; accept the trust prompt once):
  Terminal 1:  claude --agent pykit:planck     then describe what you want to build
  Terminal 2:  claude --agent pykit:cody       then /pykit:start 1   (after Planck approves phase 1)
Commit .claude/settings.json, CLAUDE.md and the control docs so other clones get the same setup.
EOF
