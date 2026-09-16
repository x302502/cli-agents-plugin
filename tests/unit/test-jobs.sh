#!/usr/bin/env bash
# Job-control suite. TC-J1..J6.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export CLI_AGENTS_JOB_DIR=$(mktemp -d); trap 'rm -rf "$CLI_AGENTS_JOB_DIR"' EXIT
J() { bash "$ROOT/scripts/jobs.sh" "$@"; }
PASS=0; FAIL=0
ok(){ PASS=$((PASS+1)); }
bad(){ FAIL=$((FAIL+1)); echo "FAIL: $1"; }
D(){ echo "$CLI_AGENTS_JOB_DIR"; }

# TC-J1 start: id format + running status
id=$(J start --cwd /tmp -- 'echo hello-job')
case "$id" in ja_*) ok;; *) bad "job id format: $id";; esac
[ "$(cat "$(D)/$id/status" 2>/dev/null)" = "running" ] && ok || bad "status not running for $id"

# TC-J2 finish: exit=0, done, result shows log
sleep 1
J result "$id" | grep -q 'hello-job' && ok || bad "result missing log content"
[ "$(cat "$(D)/$id/exit")" = "0" ] && ok || bad "exit != 0"
[ "$(cat "$(D)/$id/status")" = "done" ] && ok || bad "status != done"

# TC-J3 PATH snapshot (the node-version fix)
id3=$(J start --cwd /tmp -- "echo PATH=\$PATH")
sleep 1
J result "$id3" | grep -qF "PATH=$PATH" && ok || bad "caller PATH not restored in job (got: $(grep PATH "$(D)/$id3/log" | head -c 80))"

# TC-J4 cancel kills whole process tree (no orphans)
id4=$(J start --cwd /tmp -- 'sleep 300 & sleep 300 & wait')
sleep 1
J cancel "$id4" >/dev/null
sleep 1
c=$(pgrep -f 'sleep 300' | wc -l | tr -d ' ')
[ "$c" = "0" ] && ok || bad "orphans after cancel: $c"
[ "$(cat "$(D)/$id4/status")" = "cancelled" ] && ok || bad "status != cancelled after cancel"

# TC-J5 quoting-contract WARNING on multi-arg start
w=$(J start --cwd /tmp -- echo hi 2>&1 >/dev/null)
echo "$w" | grep -q 'WARNING' && ok || bad "multi-arg warning missing: [$w]"

# TC-J6 clean removes finished jobs, keeps running ones
id6=$(J start --cwd /tmp -- 'sleep 30')
sleep 1
J clean >/dev/null
[ -d "$(D)/$id" ] && bad "clean removed done job $id" || ok
[ -d "$(D)/$id6" ] && ok || bad "clean removed running job $id6"
J cancel "$id6" >/dev/null 2>&1 || true

echo "=== jobs: $PASS pass, $FAIL fail ==="
[ "$FAIL" = 0 ] || exit 1