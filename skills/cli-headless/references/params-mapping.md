# Params Mapping — Equivalent Flags Across CLIs

Translate a generic intent into the right flag for each CLI. Combine with the per-CLI folders
(`references/<binary>/`, indexed in `references/README.md`). Values were verified against
the installed binaries' `--help`. Supported CLIs: `claude`, `codex`, `agy`, `grok`, `pi`,
`opencode`, `cline`, `omp` (more planned — see the README roadmap).

## 1. One-shot / non-interactive (required for every delegation)

| CLI | Flag |
|---|---|
| `claude` | `-p`, `--print` |
| `codex` | `codex exec` |
| `agy` | `-p`, `--print` |
| `grok` | `-p`, `--single` |
| `pi` | `-p`, `--print` |
| `opencode` | `opencode run` |
| `cline` | `cline "<prompt>"` (default) |
| `omp` | `-p`, `--print` |

## 2. Auto-approve / permissions

| CLI | Flag | Notes |
|---|---|---|
| `claude` | `--permission-mode dontAsk` | `--dangerously-skip-permissions` only in isolated sandboxes |
| `codex` | `--dangerously-bypass-approvals-and-sandbox` | or `-s workspace-write` with automatic review |
| `agy` | `--dangerously-skip-permissions` | |
| `grok` | `--permission-mode dontAsk` / `--always-approve` | |
| `pi` | automatic in `-p` | deny shell with `--exclude-tools bash` |
| `opencode` | `--auto` | |
| `cline` | `--auto-approve true` (default) | |
| `omp` | `--auto-approve` / `--approval-mode yolo` | read-only: omit it and pin `--tools read,grep,glob` |

## 3. Structured output (machine-parseable)

| CLI | Flag |
|---|---|
| `claude` | `--output-format json\|stream-json` |
| `codex` | `--json` (+ `-o <file>`) |
| `agy` | `--output-format json\|stream-json` |
| `grok` | `--output-format json\|streaming-json` |
| `pi` | `--mode json` (NDJSON) |
| `opencode` | `--format json` |
| `cline` | `--json` |
| `omp` | `--mode json` (NDJSON, same schema as `pi`) |

## 4. JSON-schema enforcement

| CLI | Flag |
|---|---|
| `claude` | `--json-schema <schema\|file>` |
| `codex` | `--output-schema <file>` |
| `agy` | `--json-schema <schema\|file>` |
| `grok` | `--json-schema <schema>` (implies json) |

`pi`, `omp`, `opencode`, `cline` have **no native schema flag** — enforce via the prompt:
*"Return JSON matching this schema exactly; add no prose or markdown fences."*

## 5. Cost / turn / time limits

| CLI | Flag | Meaning |
|---|---|---|
| `claude` | `--max-budget-usd <n>` | hard USD cap |
| `claude` | `--max-turns <n>` | reasoning/tool turn cap |
| `grok` | `--max-turns <n>` | turn cap |
| `agy` | `--print-timeout <3m>` | print-mode timeout |
| `cline` | `-t, --timeout <s>` | process timeout |
| `cline` | `--retries <n>` | max consecutive-error retries |
| `omp` | `--max-time <600\|10m\|1h>` | session wall-clock cap (no USD/turn cap) |
| all | OS-level timeout via the `TO` helper | universal backstop (`exit 124`) |

## 6. Session / ephemeral (keep CI clean)

| CLI | Flag |
|---|---|
| `claude` | `--no-session-persistence` |
| `codex` | `--ephemeral` |
| `pi` | `--no-session` |
| `omp` | `--no-session` |
| `opencode` | auto (per UUID) |
| `cline` | auto cleanup |
| `agy` / `grok` | check `<cli> --help` for a session flag |


## 7. Tool allow / deny (security perimeter)

| CLI | Allow | Deny |
|---|---|---|
| `claude` | `--allowedTools "Read" "Grep" "Glob" "Edit" ...` | `--disallowedTools "Bash(rm *)" "Bash(sudo *)" "Bash(git push --force*)" "Bash(cat *.env*)" "mcp__*"` |
| `codex` | `-s workspace-write` (policy) | `-s read-only` (policy) |
| `pi` | `--tools read,grep,find,ls` | `--exclude-tools bash` |
| `grok` | `--allow "RULE"` | `--deny "Bash(rm *)"` |
| `omp` | `--tools read,grep,glob,write` | `--no-tools` (disable all built-ins) |

## 8. Isolated git worktree (safe write mode)

| CLI | Flag |
|---|---|
| `grok` | `-w, --worktree [name]` |
| all others | create one in the wrapper: `git worktree add -b <branch> "$TMP" HEAD` |

## 9. Model selection

| CLI | Flag |
|---|---|
| `claude` | `--model` |
| `codex` | `-m, --model` |
| `agy` | `--model` |
| `grok` | `-m, --model` |
| `pi` | `--model` |
| `opencode` | `-m <provider/model>` |
| `cline` | `-m, --model` (+ `-P --provider`) |
| `omp` | `--model <fuzzy>` (role flags `--smol` / `--slow` / `--plan`; `--provider` is legacy) |

## 10. Server / ACP daemon

| CLI | Daemon | Client attach |
|---|---|---|
| `opencode` | `opencode serve --port <p> --hostname 0.0.0.0` | `opencode run --attach <url>` |
| ACP server | `opencode acp`, `omp acp`, `cline --acp`, `agy remote-control`, `codex app-server` | — |

## 11. Recommended presets by scenario

| Scenario | Preset |
|---|---|
| Read-only triage / review | `codex exec --sandbox read-only --json` or `claude -p --permission-mode dontAsk` (low `TO` timeout) |
| Second opinion (other vendor) | `grok -p --permission-mode dontAsk --output-format json` |
| Huge-context scan | `agy -p --mode plan --output-format json` |
| Fast micro-fix | `pi -p --mode json --no-session --tools read,edit,write` |
| Guarded auto-fix | `cline "<task>" --json --timeout 240` (auto-approve default) |
| Repo work in an isolated worktree | `grok -p -w <name> --permission-mode dontAsk` |
| Cost-optimized plan then cheap execute | `omp -p --plan-yolo --plan-yolo-into claude-haiku --mode json --no-session` |
| LSP/type-aware edit on a large codebase | `omp -p --mode json --no-session --auto-approve` |

## 12. Recommended models by CLI (summary)

Fast/cheap vs default vs strongest. Full detail (tiers + the provider / model-id list) lives in
each `references/<binary>/models.md`.

| CLI | Fast / cheap | Default | Strongest | List models with |
|---|---|---|---|---|
| `claude` | `haiku` | `sonnet` | `opus` | aliases in `claude --help` |
| `codex` | `gpt-5.4-mini` | `gpt-5.4` | newest `gpt-5.6-*` / `gpt-6-*` | `-m` (`o3` also ok) |
| `agy` | `...-flash` | mid `...-pro-*` | largest Pro + `--effort high` | `--model` |
| `grok` | (unset) | account default | pinned model | `-m, --model` |
| `pi` | `claude-haiku-4.5` / `gpt-5.4-mini` | `claude-sonnet-5` | `claude-opus-5` | `pi --list-models` |
| `opencode` | `opencode/mimo-v2.5-free` | provider `.../sonnet` | provider `.../opus` | `opencode models` |
| `cline` | a `-mini` variant | provider default | newest flagship | `-m` + `-P` |
| `omp` | `claude-haiku-4.5` (`--smol`) | `claude-sonnet-5` (`--model`) | `claude-opus-5` (`--slow`) | `omp models` |

**Rule of thumb:** pick the cheapest tier that passes; escalate only for security /
high-risk work or hard cross-file reasoning. Pin the model in CI for reproducibility.

