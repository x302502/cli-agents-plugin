#!/usr/bin/env bash
# cli-agents — lightweight one-shot job control (Bash only, no app-server).
#
# State: ${CLI_AGENTS_JOB_DIR:-$HOME/.claude/cli-agents/jobs}/<job-id>/
#   cmd cwd started pid status exit log
set -uo pipefail

SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JOB_DIR="${CLI_AGENTS_JOB_DIR:-$HOME/.claude/cli-agents/jobs}"
mkdir -p "$JOB_DIR"

now() { date -u +%Y-%m-%dT%H:%M:%SZ; }
new_id() { echo "ja_$(date +%Y%m%d%H%M%S)_${RANDOM}${RANDOM}"; }

usage() {
  cat <<'USAGE'
usage: jobs.sh <command> [args]
  start [--cwd DIR] -- <command...>   launch detached; prints the job id
  status [job-id]                     list jobs, or show one
  result <job-id>                     status line + full log
  cancel <job-id>                     kill the job's process tree
  clean [--all]                       remove finished jobs (all with --all)
USAGE
}

cmd_start() {
  local cwd="$PWD"
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --cwd) cwd="$2"; shift 2 ;;
      --) shift; break ;;
      *) break ;;
    esac
  done
  [ "$#" -gt 0 ] || { echo "usage: jobs.sh start [--cwd DIR] -- <command...>" >&2; exit 2; }
  local id dir cmd
  id="$(new_id)"; dir="$JOB_DIR/$id"; mkdir -p "$dir"
  # Contract: pass the command as ONE shell-quoted string. Multiple args are joined
  # with spaces (best effort) — always quote the whole command at the call site.
  if [ "$#" -eq 1 ]; then cmd="$1"; else cmd="$*"; printf 'jobs.sh: WARNING: got %s args; joined with spaces. Pass ONE quoted string to preserve quoting.\n' "$#" >&2; fi
  printf '%s\n' "$cmd" > "$dir/cmd"
  printf '%s\n' "$cwd" > "$dir/cwd"
  printf '%s\n' "$(now)" > "$dir/started"
  printf 'running\n' > "$dir/status"
  # Put the job in its own process group (setsid) when available, so cancel can signal the
  # whole group; otherwise jobs.sh falls back to walking the descendant tree.
  if command -v setsid >/dev/null 2>&1; then
    setsid nohup bash "$SELF_DIR/job-runner.sh" "$dir" >/dev/null 2>&1 &
  else
    nohup bash "$SELF_DIR/job-runner.sh" "$dir" >/dev/null 2>&1 &
  fi
  echo $! > "$dir/pid"
  disown 2>/dev/null || true
  echo "$id"
}

cmd_status() {
  local id="${1:-}"
  shopt -s nullglob
  if [ -z "$id" ]; then
    local any=0 d j
    for d in "$JOB_DIR"/*/; do
      any=1; j="$(basename "$d")"
      printf '%-30s status=%-8s exit=%-5s started=%-21s %s\n' \
        "$j" "$(cat "$d/status" 2>/dev/null)" "$(cat "$d/exit" 2>/dev/null || echo -)" \
        "$(cat "$d/started" 2>/dev/null)" "$(head -c 80 "$d/cmd" 2>/dev/null)"
    done
    [ "$any" = 1 ] || echo "(no jobs)"
    return
  fi
  local d="$JOB_DIR/$id"
  [ -d "$d" ] || { echo "no such job: $id" >&2; exit 1; }
  printf 'id:      %s\nstatus:  %s\nexit:    %s\nstarted: %s\ncwd:     %s\ncmd:     %s\nlog:     %s\n' \
    "$id" "$(cat "$d/status" 2>/dev/null)" "$(cat "$d/exit" 2>/dev/null || echo -)" \
    "$(cat "$d/started" 2>/dev/null)" "$(cat "$d/cwd" 2>/dev/null)" \
    "$(cat "$d/cmd" 2>/dev/null)" "$d/log"
}

cmd_result() {
  local id="${1:-}"; [ -n "$id" ] || { echo "usage: jobs.sh result <job-id>" >&2; exit 2; }
  local d="$JOB_DIR/$id"; [ -d "$d" ] || { echo "no such job: $id" >&2; exit 1; }
  printf '=== job %s | status=%s exit=%s ===\n' \
    "$id" "$(cat "$d/status" 2>/dev/null)" "$(cat "$d/exit" 2>/dev/null || echo -)"
  cat "$d/log" 2>/dev/null || true
}

# Kill a process and ALL of its descendants (children first), so a delegated CLI that
# spawns its own subprocesses/workers does not survive a cancel as an orphan.
kill_tree() {
  local pid="$1" sig="${2:-TERM}" k kids
  kids="$(pgrep -P "$pid" 2>/dev/null || true)"
  for k in $kids; do kill_tree "$k" "$sig"; done
  kill -"$sig" "$pid" 2>/dev/null || true
}

cmd_cancel() {
  local id="${1:-}"; [ -n "$id" ] || { echo "usage: jobs.sh cancel <job-id>" >&2; exit 2; }
  local d="$JOB_DIR/$id"; [ -d "$d" ] || { echo "no such job: $id" >&2; exit 1; }
  local pid; pid="$(cat "$d/pid" 2>/dev/null || true)"
  if [ -z "$pid" ] || ! kill -0 "$pid" 2>/dev/null; then
    echo "not running: $id"
    return
  fi

  # 1) If the job leads its own process group (started via setsid), signal the whole group.
  kill -TERM "-$pid" 2>/dev/null || true
  # 2) Always also walk the descendant tree — covers the no-setsid fallback and stragglers.
  kill_tree "$pid" TERM

  sleep 2
  if kill -0 "$pid" 2>/dev/null; then
    kill -KILL "-$pid" 2>/dev/null || true
    kill_tree "$pid" KILL
  fi

  printf 'cancelled\n' > "$d/status"; printf '130\n' > "$d/exit"
  echo "cancelled: $id"
}

cmd_clean() {
  local all=0; [ "${1:-}" = "--all" ] && all=1
  shopt -s nullglob
  local d
  for d in "$JOB_DIR"/*/; do
    if [ "$all" = 1 ] || [ "$(cat "$d/status" 2>/dev/null)" = "done" ]; then rm -rf "$d"; fi
  done
  echo "cleaned"
}

case "${1:-}" in
  start) shift; cmd_start "$@" ;;
  status|list) shift; cmd_status "${1:-}" ;;
  result) shift; cmd_result "${1:-}" ;;
  cancel) shift; cmd_cancel "${1:-}" ;;
  clean) shift; cmd_clean "${1:-}" ;;
  ""|-h|--help|help) usage ;;
  *) echo "unknown command: $1" >&2; usage; exit 2 ;;
esac
