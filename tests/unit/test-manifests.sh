#!/usr/bin/env bash
# Static/manifest suite for cli-agents (offline, no CLIs needed). TC-M1..M10.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"
PASS=0; FAIL=0
ok(){ PASS=$((PASS+1)); }
bad(){ FAIL=$((FAIL+1)); echo "FAIL: $1"; }

# TC-M1 all JSON valid
for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json hooks/hooks.json schemas/delegation-report.schema.json schemas/review-output.schema.json; do
  jq empty "$f" 2>/dev/null && ok || bad "JSON invalid: $f"
done

# TC-M2 versions match
v1=$(jq -r .version .claude-plugin/plugin.json); v2=$(jq -r .metadata.version .claude-plugin/marketplace.json)
[ "$v1" = "$v2" ] && ok || bad "version mismatch plugin=$v1 marketplace=$v2"

# TC-M3 manifest essentials (Claude Code splits agents/skills/commands into folders, not
# top-level manifest keys — so verify the manifest core + that the entry folders exist)
jq -e 'has("name") and (.author|type=="object" and has("name"))' .claude-plugin/plugin.json >/dev/null 2>&1 && ok || bad "plugin.json missing name or author object"
[ -d agents ] && [ -d skills/cli-headless ] && [ -d skills/delegation-result ] && [ -d commands ] && ok || bad "agents/skills/commands folders missing"

# TC-M4+M5 frontmatter + fences (also every ref md balanced)
#   agents & skills: require name + description,
#   commands: require description (+ optional argument-hint/allowed-tools)
if python3 - "$ROOT" <<'PY' 2>/dev/null; then ok; else bad "frontmatter or fences"; fi
import re,yaml,glob,sys
root=sys.argv[1]
for f in glob.glob(root+'/agents/*.md')+glob.glob(root+'/skills/**/SKILL.md',recursive=True):
    t=open(f).read(); parts=t.split('---')
    y=yaml.safe_load(parts[1]) if len(parts)>2 else {}
    assert y.get('name') and y.get('description'), f
    assert len(re.findall(r'^```',t,re.M))%2==0, 'fences '+f
for f in glob.glob(root+'/commands/*.md'):
    t=open(f).read(); parts=t.split('---')
    y=yaml.safe_load(parts[1]) if len(parts)>2 else {}
    assert y.get('description'), f
    assert len(re.findall(r'^```',t,re.M))%2==0, 'fences '+f
for f in glob.glob(root+'/**/*.md',recursive=True):
    assert len(re.findall(r'^```',open(f).read(),re.M))%2==0, 'fences '+f
PY

# TC-M6 supported-CLI list consistent across the 4 canonical places
EXPECT="agy claude cline codex grok omp opencode pi"
got=$(bash scripts/check-setup.sh | tail -n +3 | awk '{print $1}' | sort | tr '\n' ' ' | sed 's/ $//')
[ "$got" = "$EXPECT" ] && ok || bad "check-setup list: got [$got] want [$EXPECT]"
agent_loop=$(grep -o 'for c in [a-z -]*; do' agents/cli-delegate.md | sed 's/for c in //;s/; do//')
[ "$agent_loop" = "$EXPECT" ] && ok || bad "agent loop: [$agent_loop]"
for c in $EXPECT; do
  grep -qw "$c" commands/delegate.md && grep -qw "$c" README.md && ok || bad "CLI $c missing in delegate.md or README"
done

# TC-M7 every folder ships README+models, and only supported folders exist
for c in $EXPECT; do
  [ -f "skills/cli-headless/references/$c/README.md" ] && [ -f "skills/cli-headless/references/$c/models.md" ] && ok || bad "missing ref files for $c"
done
for d in skills/cli-headless/references/*/; do
  c=$(basename "$d")
  case " $EXPECT " in *" $c "*) ok;; *) bad "phantom folder: $c";; esac
done

# TC-M8 script syntax
for f in scripts/*.sh; do bash -n "$f" 2>/dev/null && ok || bad "syntax: $f"; done

# TC-M9 report schema requires 11 fields
n=$(jq '.required|length' schemas/delegation-report.schema.json)
[ "$n" = 11 ] && ok || bad "schema required=$n != 11"

# TC-M10 restore instructions in README
grep -q 'git revert' README.md && ok || bad "README restore instructions missing"

echo "=== manifests: $PASS pass, $FAIL fail ==="
[ "$FAIL" = 0 ] || exit 1