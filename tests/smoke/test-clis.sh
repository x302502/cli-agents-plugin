#!/usr/bin/env bash
# Live CLI smoke suite (opt-in via SMOKE=1). TC-S1..S8.
# Each supported CLI runs its canonical one-shot recipe on "Reply with exactly: OK";
# pass = exit 0 AND output contains OK. Filter with SMOKE_CLIS="codex,pi".
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
mkdir -p "$ROOT/tmp"
P="Reply with exactly: OK"
TO() { local s="$1"; shift;
  if command -v timeout  >/dev/null 2>&1; then timeout  "$s" "$@"; return; fi
  if command -v gtimeout >/dev/null 2>&1; then gtimeout "$s" "$@"; return; fi
  perl -e 'my $t=shift; my $p=fork(); if(!$p){exec @ARGV; exit 127}
           $SIG{ALRM}=sub{kill "TERM",$p; sleep 2; kill "KILL",$p; exit 124};
           alarm $t; waitpid($p,0); exit($?>>8)' "$s" "$@"
}
PASS=0; FAIL=0
run(){ # name logfile cmd...
  local name="$1" log="$2"; shift 2
  "$@" >"$log" 2>&1 </dev/null
  local rc=$?
  if [ $rc -eq 0 ] && grep -q 'OK' "$log"; then PASS=$((PASS+1)); echo "PASS  $name (rc=$rc)";
  else FAIL=$((FAIL+1)); echo "FAIL  $name (rc=$rc)"; tail -n 6 "$log" | cut -c1-160; fi
}
ALL=${SMOKE_CLIS:-agy claude cline codex grok opencode pi}
echo "=== CLI smoke ($(date -u +%H:%M:%S), CLIs: $ALL) ==="
for c in $ALL; do
  case "$c" in
    claude)   run claude   "$ROOT/tmp/smoke-claude.log"   TO 60 claude -p "$P" --permission-mode dontAsk --allowedTools Read Grep Glob --max-turns 2 --no-session-persistence ;;
    codex)    run codex    "$ROOT/tmp/smoke-codex.log"    TO 60 codex exec "$P" --sandbox read-only --ephemeral --skip-git-repo-check --json -o "$ROOT/tmp/codex-last.txt" ;;
    agy)      run agy      "$ROOT/tmp/smoke-agy.log"      TO 60 agy -p "$P" --mode plan --output-format json --print-timeout 45s ;;
    grok)     run grok     "$ROOT/tmp/smoke-grok.log"     TO 60 grok -p "$P" --permission-mode dontAsk --output-format json --max-turns 3 ;;
    pi)       run pi       "$ROOT/tmp/smoke-pi.log"       TO 60 pi -p "$P" --mode json --no-session --no-context-files --tools read,grep,find,ls ;;
    opencode) run opencode "$ROOT/tmp/smoke-opencode.log" TO 60 opencode run "$P" --pure --auto --format json ;;
    cline)    run cline    "$ROOT/tmp/smoke-cline.log"    TO 60 cline "$P" --json --timeout 50 ;;
    *) echo "SKIP  $c (unsupported)";;
  esac
done
echo "=== smoke: $PASS pass, $FAIL fail ==="
[ "$FAIL" = 0 ] || exit 1