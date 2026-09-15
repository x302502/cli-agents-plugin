#!/usr/bin/env bash
# internal runner for jobs.sh — executes the stored command, records exit + status.
set -uo pipefail
dir="${1:?job dir required}"
cd "$(cat "$dir/cwd" 2>/dev/null)" 2>/dev/null || true
# Prefer the PATH snapshotted from the calling session (where the user's CLIs are
# verified working — e.g. the right node version behind #!/usr/bin/env wrappers).
# Fall back to the login PATH (finds nvm/~/.local CLIs) for foreign/legacy job dirs.
parent_path="$(cat "$dir/path" 2>/dev/null || true)"
if [ -n "$parent_path" ]; then
  export PATH="$parent_path"
else
  login_path="$(bash -lc 'printf %s "$PATH"' 2>/dev/null || true)"
  [ -n "$login_path" ] && export PATH="$login_path"
fi
bash -c "$(cat "$dir/cmd")" >"$dir/log" 2>&1
echo $? > "$dir/exit"
echo done > "$dir/status"
