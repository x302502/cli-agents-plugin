#!/usr/bin/env bash
# Report which delegable CLI agents are installed on this machine.
set -uo pipefail
clis="agy claude cline codex grok opencode pi"
printf '%-14s %-10s %s\n' CLI INSTALLED PATH
printf '%-14s %-10s %s\n' ---- --------- ----
for c in $clis; do
  if command -v "$c" >/dev/null 2>&1; then
    printf '%-14s %-10s %s\n' "$c" yes "$(command -v "$c")"
  else
    printf '%-14s %-10s %s\n' "$c" no -
  fi
done
