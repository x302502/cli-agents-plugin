#!/usr/bin/env bash
# internal runner for jobs.sh — executes the stored command, records exit + status.
set -uo pipefail
dir="${1:?job dir required}"
cd "$(cat "$dir/cwd" 2>/dev/null)" 2>/dev/null || true
# Inherit the login PATH once (finds nvm/~/.local CLIs) without re-sourcing the
# profile on every run (which would leak profile errors into the job log).
login_path="$(bash -lc 'printf %s "$PATH"' 2>/dev/null || true)"
[ -n "$login_path" ] && export PATH="$login_path"
bash -c "$(cat "$dir/cmd")" >"$dir/log" 2>&1
echo $? > "$dir/exit"
echo done > "$dir/status"
