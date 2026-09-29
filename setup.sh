#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: setup.sh [--update-agents] [project-dir]" >&2
  echo "  --update-agents  replace project agent/template copies with the kit's versions (edited files are backed up)" >&2
  echo "  env PYKIT_SOURCE=owner/repo|path overrides the marketplace source" >&2
  exit 1
}
update_agents=0
target=""
for arg in "$@"; do
  case "$arg" in
    -h|--help) usage ;;
    --update-agents) update_agents=1 ;;
    -*) usage ;;
    *) [ -z "$target" ] || usage; target="$arg" ;;
  esac
done

kit="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project="$(cd "${target:-$PWD}" && pwd -P)"
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
top="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[ -n "$top" ] && top="$(cd "$top" && pwd -P)"
if [ "$top" != "$project" ]; then
  if [ -n "$top" ]; then
    echo "note: $project is inside another git repo ($top); creating a separate repo for this project"
  fi
  git init -q -b main
  echo "initialized git repo in $project (branch main)"
fi

echo "marketplace source: $source"
claude plugin validate "$kit"
if ! claude plugin marketplace list 2>/dev/null | grep -q 'claude-plugins-official'; then
  claude plugin marketplace add anthropics/claude-plugins-official
fi
mkt=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["name"])' "$kit/.claude-plugin/marketplace.json")
claude plugin marketplace add "$source" --scope project
claude plugin install "pykit@$mkt" --scope project

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

python3 - "$kit/plugins/pykit" "$update_agents" <<'PY'
import hashlib, json, pathlib, shutil, sys, time
src_root, update = pathlib.Path(sys.argv[1]), sys.argv[2] == "1"
manifest_path = pathlib.Path(".claude/pykit/manifest.json")
manifest = json.loads(manifest_path.read_text()) if manifest_path.exists() else {}
stamp = time.strftime("%Y%m%d%H%M%S")
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
pairs = [(f, pathlib.Path(".claude/agents") / f.name) for f in sorted((src_root / "agents").glob("*.md"))]
pairs += [(f, pathlib.Path(".claude/pykit/templates") / f.name) for f in sorted((src_root / "templates").glob("*.md")) if f.name != "claude-block.md"]
pending = []
for src, dst in pairs:
    key = str(dst)
    if not dst.exists():
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(src, dst); manifest[key] = sha(dst)
        print(f"created {dst}")
        continue
    if sha(dst) == sha(src):
        manifest[key] = sha(dst)
        continue
    edited = manifest.get(key) != sha(dst)
    if not update:
        pending.append(f"{dst} ({'edited locally' if edited else 'kit has a newer version'})")
        continue
    if edited:
        backup = dst.with_name(f"{dst.name}.bak-{stamp}")
        shutil.copyfile(dst, backup)
        print(f"backed up edited {dst} -> {backup}")
    shutil.copyfile(src, dst); manifest[key] = sha(dst)
    print(f"updated {dst}")
manifest_path.parent.mkdir(parents=True, exist_ok=True)
manifest_path.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
if pending:
    print("kept project copies that differ from the kit (run with --update-agents to replace; edits get a .bak):")
    for line in pending: print(f"  {line}")
PY

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

if [ -f STATE.md ] && ! grep -q '^## Phases' STATE.md; then
  echo "note: STATE.md predates the pykit 0.4 tracker format. Ask Planck to migrate it (\"migrate STATE.md to .claude/pykit/templates/STATE.md\"), or replace it with that template."
fi

for entry in .pykit/ .playwright-mcp/; do
  if ! grep -qxF "$entry" .gitignore 2>/dev/null; then
    printf '%s\n' "$entry" >> .gitignore
    echo "added $entry to .gitignore"
  fi
done

command -v gh >/dev/null || echo "optional: install the GitHub CLI so Shipy can open PRs: brew install gh && gh auth login"

cat <<EOF

Pykit is set up in $project
Installed: pykit (/pykit:* commands) + playwright + context7${lsp:+ + $lsp}
Agents:    .claude/agents/{planck,cody,tessma,revy,sid,summa,shipy}.md  (edit freely; these override the plugin)

Next: exit this session and start NEW ones (plugins load at startup; accept the trust prompt once):
  Terminal 1:  claude --agent planck     then describe what you want to build
  Terminal 2:  claude --agent cody       then /pykit:start 1   (after Planck approves phase 1)
Commit .claude/ (settings, agents, pykit templates), CLAUDE.md and the control docs so other clones get the same setup.
EOF
