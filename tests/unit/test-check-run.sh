#!/usr/bin/env bash
# Classifier suite. TC-C1..C10: check-run.sh must map fixture logs to the right TYPE.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
PASS=0; FAIL=0
chk(){ # name log exitcode expected
  local out; out=$(bash "$ROOT/scripts/check-run.sh" "$2" "$3" 2>/dev/null | cut -f1)
  if [ "$out" = "$4" ]; then PASS=$((PASS+1)); else FAIL=$((FAIL+1)); echo "FAIL: $1 got=$out want=$4"; fi
}
t=$TMP

printf 'all good\n'              > "$t/ok.log";      chk C1-OK             "$t/ok.log"      0 OK
printf 'anything\n'              > "$t/timeout.log"; chk C2-TIMEOUT        "$t/timeout.log" 124 TIMEOUT
printf 'bash: codex: command not found\n' > "$t/missing.log"; chk C3-CLI_MISSING "$t/missing.log" 1 CLI_MISSING
printf 'not authenticated\n'     > "$t/auth.log";    chk C4-AUTH           "$t/auth.log"    1 AUTH
printf 'HTTP 429 Too Many Requests\n' > "$t/rate.log"; chk C5-RATE_LIMIT   "$t/rate.log"    1 RATE_LIMIT
printf 'unknown option: --wat\n' > "$t/flags.log";   chk C6-BAD_FLAGS      "$t/flags.log"   1 BAD_FLAGS
printf 'context length exceeded\n' > "$t/ctx.log";   chk C7-CONTEXT_OVERFLOW "$t/ctx.log"   1 CONTEXT_OVERFLOW
printf 'permission denied reading\n' > "$t/perm.log"; chk C8-PERMISSION    "$t/perm.log"    1 PERMISSION
printf 'some generic failure\n'  > "$t/nz.log";      chk C9-NONZERO_EXIT   "$t/nz.log"      3 NONZERO_EXIT
: > "$t/empty.log";                                  chk C10-EMPTY_OUTPUT  "$t/empty.log"   0 EMPTY_OUTPUT

echo "=== check-run: $PASS pass, $FAIL fail ==="
[ "$FAIL" = 0 ] || exit 1