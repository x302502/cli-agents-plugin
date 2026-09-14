#!/usr/bin/env bash
# Optional Stop hook: one-shot review gate. OFF by default.
# Enable: export CLI_AGENTS_REVIEW_GATE=1  OR  touch ~/.claude/cli-agents/review-gate.on
set -uo pipefail

MARKER="${CLI_AGENTS_REVIEW_GATE_FILE:-$HOME/.claude/cli-agents/review-gate.on}"
enabled=0
[ "${CLI_AGENTS_REVIEW_GATE:-0}" = "1" ] && enabled=1
[ -f "$MARKER" ] && enabled=1
[ "$enabled" = 1 ] || exit 0

cat >/dev/null 2>&1 || true   # drain hook payload

CLI="${CLI_AGENTS_REVIEW_CLI:-codex}"
command -v "$CLI" >/dev/null 2>&1 || exit 0
[ "$CLI" = "codex" ] || exit 0   # gate implemented for codex only

TO() { local s="$1"; shift
  if command -v timeout  >/dev/null 2>&1; then timeout  "$s" "$@"; return; fi
  if command -v gtimeout >/dev/null 2>&1; then gtimeout "$s" "$@"; return; fi
  perl -e 'my $t=shift; my $p=fork(); if(!$p){exec @ARGV; exit 127}
           $SIG{ALRM}=sub{kill "TERM",$p; sleep 2; kill "KILL",$p; exit 124}
           alarm $t; waitpid($p,0); exit($?>>8)' "$s" "$@"
}

OUT="${TMPDIR:-/tmp}/cli-agents-gate.json"
PROMPT='Review the current git working tree for material risks. Return ONLY a JSON object: {"verdict":"approve"|"needs-attention","summary":"...","findings":[{"severity":"critical|high|medium|low","title":"...","body":"...","file":"...","line_start":1,"line_end":1,"confidence":0.0,"recommendation":"..."}],"next_steps":["..."]}'
TO 300 codex exec "$PROMPT" --sandbox read-only --ephemeral --skip-git-repo-check --json -o "$OUT" >/dev/null 2>&1 || true
REVIEW="$(cat "$OUT" 2>/dev/null || true)"

if printf '%s' "$REVIEW" | grep -qiE '"verdict"[[:space:]]*:[[:space:]]*"needs-attention"'; then
  echo "cli-agents review gate: Codex flagged issues. Address them, or disable with: rm ~/.claude/cli-agents/review-gate.on" >&2
  printf '%s\n' "$REVIEW" >&2
  exit 2
fi
exit 0
