#!/usr/bin/env bash
# TO-helper suite. TC-T1..T6: the perl timeout helper documented in SKILL.md must actually
# work. Regression guard for the missing `;` after the sub{} block, which made every call
# die with `syntax error near "alarm"` and exit 255 instead of running / exiting 124.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
PASS=0; FAIL=0
chk(){ # name got want
  if [ "$2" = "$3" ]; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); echo "FAIL: $1 got=$2 want=$3"; fi
}

# Extract the TO() block exactly as documented (first occurrence) and source it.
awk '/^TO\(\) \{/{f=1} f{print} f&&/^\}/{exit}' \
  "$ROOT/skills/cli-headless/SKILL.md" > "$TMP/to.sh"
# shellcheck disable=SC1091
. "$TMP/to.sh"

# T1 documented helper runs a normal command and propagates exit 0
TO 5 echo ok >/dev/null 2>&1; chk T1-normal-exit0 "$?" 0
# T2 documented helper times out with 124 (not 255 = perl syntax error)
TO 1 sleep 5 >/dev/null 2>&1; chk T2-timeout-124 "$?" 124
# T3 child exit code is propagated
TO 5 bash -c 'exit 7' >/dev/null 2>&1; chk T3-child-exit-propagated "$?" 7
# T4 multi-word / quoted arguments survive
out=$(TO 5 bash -c 'echo "two words"' 2>/dev/null); chk T4-args-preserved "$out" "two words"
# T5 the documented ONE-LINE form (agents often inline it into a single Bash call) works
grep -m1 -F 'TO() { local s="$1"; shift; if command' \
  "$ROOT/skills/cli-headless/SKILL.md" > "$TMP/to-oneline.sh"
printf 'TO 5 echo oneline\n' >> "$TMP/to-oneline.sh"
bash "$TMP/to-oneline.sh" >/dev/null 2>&1; chk T5-oneline-exit0 "$?" 0
# T6 no TO definition in the repo is missing the `;` after the sub{} block
bad=$(grep -rn 'exit 124}$' --include='*.md' --include='*.sh' "$ROOT" 2>/dev/null \
      | grep -v '/.git/' | wc -l | tr -d ' ')
chk T6-no-missing-semicolon "$bad" 0
# T7 the one-line form also times out with 124
{ grep -m1 -F 'TO() { local s="$1"; shift; if command' "$ROOT/skills/cli-headless/SKILL.md"; \
  printf 'TO 1 sleep 5\n'; } > "$TMP/to-oneline-to.sh"
bash "$TMP/to-oneline-to.sh" >/dev/null 2>&1; chk T7-oneline-timeout-124 "$?" 124

echo "=== to-helper: $PASS pass, $FAIL fail ==="
[ "$FAIL" = 0 ] || exit 1
