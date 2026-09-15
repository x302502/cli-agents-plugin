#!/usr/bin/env bash
# cli-agents — classify a CLI run from its captured log + exit code.
#
# Usage:
#   check-run.sh <log-file> [<exit-code>]
#   CLI_AGENTS_LAST_LOG=<log> check-run.sh [<exit-code>]
#
# Prints one line:  <TYPE><TAB><suggestion>
# and, unless the run is OK, a short tail of the log to stderr.
set -uo pipefail

log="${1:-}"; code="${2:-0}"
if [ -z "$log" ] && [ -n "${CLI_AGENTS_LAST_LOG:-}" ]; then log="$CLI_AGENTS_LAST_LOG"; fi
[ -n "$log" ] || { echo "usage: check-run.sh <log-file> [<exit-code>]" >&2; exit 2; }
[ -f "$log" ] || log="/dev/null"
[ -n "$code" ] || code=0

have()  { grep -qiE "$1" "$log" 2>/dev/null; }
empty() { ! grep -q '[^[:space:]]' "$log" 2>/dev/null; }

type=""; fix=""
if [ "$code" = "124" ]; then
  type="TIMEOUT";        fix="Raise the timeout or narrow the scope; or use a faster CLI."
elif [ "$code" = "127" ] || have 'command not found|no such file or directory: .*(codex|agy|grok|opencode|cline|pi)'; then
  type="CLI_MISSING";    fix="CLI not installed. Pick another CLI or install it."
elif have 'not authenticated|unauthenticated|unauthorized|401|invalid api key|no api key|please (log ?in|sign ?in)|authentication required|api key not set'; then
  type="AUTH";           fix="Authenticate the CLI (e.g. codex login, agent login, or run it once interactively) and retry."
elif have 'rate limit|429|too many requests|quota|usage limit'; then
  type="RATE_LIMIT";     fix="Back off and retry later, or switch CLI/model."
elif have 'unknown (flag|option|argument)|invalid (flag|option|argument)|unrecognized (argument|option)|unexpected argument|usage:'; then
  type="BAD_FLAGS";      fix="A flag is wrong for this CLI version. Re-check the recipe against <cli> --help."
elif have 'context (window|length) exceeded|too many tokens|maximum context|reduce the number of tokens'; then
  type="CONTEXT_OVERFLOW"; fix="Scope the input (fewer files / tail logs / summarize first)."
elif have 'permission denied|not permitted|operation not permitted|blocked by sandbox|trust'; then
  type="PERMISSION";     fix="Auto-approve flag missing or sandbox blocked it. Adjust flags (or --trust)."
elif [ "$code" != "0" ]; then
  type="NONZERO_EXIT";   fix="Inspect the log tail; retry once, then switch CLI."
elif empty; then
  type="EMPTY_OUTPUT";   fix="No output produced. Narrow the prompt or switch CLI."
else
  type="OK";             fix="Run looks successful."
fi

printf '%s\t%s\n' "$type" "$fix"
if [ "$type" != "OK" ]; then
  echo "--- log tail ($log) ---" >&2
  tail -n 20 "$log" >&2 2>/dev/null || true
fi
[ "$type" = "OK" ] || exit 1
exit 0