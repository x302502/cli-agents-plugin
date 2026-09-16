---
name: cli-headless
description: Internal invocation contract for delegating a coding, review, refactor, or analysis task to any installed headless coding-agent CLI (claude, codex, agy, grok, pi, opencode, cline, omp) with 4-pillar guardrails, timeouts, and structured output. Preloaded by the cli-agents:cli-delegate subagent.
user-invocable: false
---

# CLI Headless Runtime — Multi-CLI Invocation Contract

This skill is the invocation contract used when a task is delegated to an external headless
coding-agent CLI. It is preloaded into the `cli-agents:cli-delegate` subagent via that
agent's `skills:` frontmatter, and can also guide the main agent when it calls a CLI directly.

Keep this file lean. The detail lives in `references/` and is read on demand:

| Reference | Read it for |
|---|---|
| `references/README.md` | index — which per-CLI folder to read |
| `references/<binary>/README.md` | per-CLI overview (15): description, invocation, flags, parsing |
| `references/<binary>/models.md` | per-CLI recommended tiers + full provider / model-id list |
| `references/params-mapping.md` | translating an intent (auto-approve, json, worktree, limits, ...) into each CLI's flag; presets per scenario |
| `references/guardrails.md` | prompt building + 4-pillar + write-mode guardrails |
| `references/job-control.md` | detached jobs (`scripts/jobs.sh`) + resume/continue flags |
| `references/io-and-errors.md` | output parsing + report schema + error handling |
| `references/examples.md` | worked examples |

## Decision flow

1. Verify which CLIs are installed (agent `Step 0`).
2. Choose the CLI — the user's explicit choice wins; otherwise use `references/README.md`
   and the scenario presets in `references/params-mapping.md`.
3. Read `references/<binary>/README.md` and pick a model from
   `references/<binary>/models.md` (tiers + full provider/model-id list) unless the parent
   pinned one.
4. Apply `references/guardrails.md`: 4-pillar limits, auto-write default (guarded), timeout.
5. Run it: foreground with the `TO` helper (below) for short tasks, or detached via
   `scripts/jobs.sh start` (see `references/job-control.md`) for long ones. Parse per
   `references/io-and-errors.md` and return its `## CLI delegation report` schema.

## Quick selection

| Task shape | CLI |
|---|---|
| Strongest reasoning / cross-file correctness | `claude`, `codex` |
| Huge-context scan (1M+) | `agy` |
| Fast, cheap read-only review / docs / micro-fix | `pi`, `cline` |
| LSP/type-aware work on a large codebase; plan then cheap execute | `omp` |
| Sandboxed file work | `codex -s workspace-write` |
| Isolated git worktree (writes) | `grok -w` |
| Second opinion from another vendor | any CLI from a different family than the host |

## Portable Timeout Helper (macOS has no `timeout` by default)

This machine does **not** ship `timeout` or `gtimeout` (coreutils is not installed). Define
this helper at the top of any `Bash` call that runs a delegated CLI, then prefix the command
with `TO <seconds>`:

```bash
TO() { local s="$1"; shift;
  if command -v timeout  >/dev/null 2>&1; then timeout  "$s" "$@"; return; fi
  if command -v gtimeout >/dev/null 2>&1; then gtimeout "$s" "$@"; return; fi
  perl -e 'my $t=shift; my $p=fork(); if(!$p){exec @ARGV; exit 127}
           $SIG{ALRM}=sub{kill "TERM",$p; sleep 2; kill "KILL",$p; exit 124};
           alarm $t; waitpid($p,0); exit($?>>8)' "$s" "$@"
}
```

> **The `;` after the `sub{...}` block is REQUIRED.** Perl does not treat the newline after a
> block's closing brace as a statement terminator here, so without it the helper dies with
> `syntax error near "alarm"` and **every** call exits `255`.

If you need it on **one line** (e.g. inside a single `Bash` call), use this exact form — note
the `;` after `shift`, after each `fi`, and after `"$@"`; dropping any of them is a bash
syntax error:

```bash
TO() { local s="$1"; shift; if command -v timeout >/dev/null 2>&1; then timeout "$s" "$@"; return; fi; if command -v gtimeout >/dev/null 2>&1; then gtimeout "$s" "$@"; return; fi; perl -e 'my $t=shift; my $p=fork(); if(!$p){exec @ARGV; exit 127} $SIG{ALRM}=sub{kill "TERM",$p; sleep 2; kill "KILL",$p; exit 124}; alarm $t; waitpid($p,0); exit($?>>8)' "$s" "$@"; }
```

- Each `Bash` call is a fresh shell — re-declare `TO` in every call that needs it.
- Also pass a `timeout` to the `Bash` tool itself (e.g. 300000 ms) as a second net.
- On timeout the helper exits `124`. Report `TIMEOUT` to the parent.

## Non-negotiables

- Always non-interactive (`-p` / `exec` / `run` / `-x` / bare `cline`); redirect stderr.
- Always set a timeout; add budget/turn caps where the CLI supports them.
- Auto-write by default so the CLI completes the task and reports files changed; read-only
  when the parent passes `--read-only`; never push to `main`; never force-push.
- Prefer `json` / `stream-json`; always check **both** the exit code and the parsed payload.
