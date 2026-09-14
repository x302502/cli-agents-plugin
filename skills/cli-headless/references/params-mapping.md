# Params Mapping — Equivalent Flags Across CLIs

Translate a generic intent into the right flag for each CLI. Combine with the per-CLI folders
(`references/<binary>/`, indexed in `references/README.md`). Values were verified against
the installed binaries' `--help`.

## 1. One-shot / non-interactive (required for every delegation)

| CLI | Flag |
|---|---|
| `claude` | `-p`, `--print` |
| `codex` | `codex exec` |
| `agy` | `-p`, `--print` |
| `grok` | `-p`, `--single` |
| `copilot` | `-p`, `--prompt` |
| `pi` | `-p`, `--print` |
| `omp` | `-p`, `--print` |
| `opencode` | `opencode run` |
| `kilo` | `kilo run` |
| `mimo` | `mimo run` |
| `amp` | `-x`, `--execute` |
| `cline` | `cline "<prompt>"` (default) |
| `command-code` | `-p`, `--print` |
| `cursor-agent` | `-p`, `--print` |
| `droid` | `droid exec` |

## 2. Auto-approve / permissions

| CLI | Flag | Notes |
|---|---|---|
| `claude` | `--permission-mode dontAsk` | `--dangerously-skip-permissions` only in isolated sandboxes |
| `codex` | `--dangerously-bypass-approvals-and-sandbox` | or `-s workspace-write` with automatic review |
| `agy` | `--dangerously-skip-permissions` | |
| `grok` | `--permission-mode dontAsk` / `--always-approve` | |
| `copilot` | `--allow-all-tools` / `--yolo` | `--yolo` also grants paths + URLs |
| `pi` | automatic in `-p` | deny shell with `--exclude-tools bash` |
| `omp` | `--plan-yolo` (plan→auto-approve) | or automatic in `-p` |
| `opencode` | `--auto` | |
| `kilo` | `--auto` (or `--dangerously-skip-permissions`) | |
| `mimo` | `--never-ask --trust` | `--trust` skips workspace-trust prompt |
| `amp` | `--dangerously-skip-permissions` | |
| `cline` | `--auto-approve true` (default) | |
| `command-code` | `--auto-accept` / `--yolo` | add `--skip-onboarding` on first/CI run |
| `cursor-agent` | `--force` / `--yolo` | add `--trust` |
| `droid` | `--auto low\|medium\|high` | `--skip-permissions-unsafe` only in containers |

## 3. Structured output (machine-parseable)

| CLI | Flag |
|---|---|
| `claude` | `--output-format json\|stream-json` |
| `codex` | `--json` (+ `-o <file>`) |
| `agy` | `--output-format json\|stream-json` |
| `grok` | `--output-format json\|streaming-json` |
| `copilot` | `--output-format json` (+ `--usage-output-file`) |
| `pi` | `--mode json` (NDJSON) |
| `omp` | `--mode json` |
| `opencode` | `--format json` |
| `kilo` | `--format json` |
| `mimo` | `--format json` |
| `amp` | `--stream-json` |
| `cline` | `--json` |
| `command-code` | `--output-format json` |
| `cursor-agent` | `--output-format json\|stream-json` |
| `droid` | `-o, --output-format json` |

## 4. JSON-schema enforcement

| CLI | Flag |
|---|---|
| `claude` | `--json-schema <schema\|file>` |
| `codex` | `--output-schema <file>` |
| `agy` | `--json-schema <schema\|file>` |
| `grok` | `--json-schema <schema>` (implies json) |

`pi`, `omp`, `opencode`, `kilo`, `mimo`, `amp`, `cline`, `copilot`, `command-code`,
`cursor-agent`, `droid` have **no native schema flag** — enforce via the prompt:
*"Return JSON matching this schema exactly; add no prose or markdown fences."*

## 5. Cost / turn / time limits

| CLI | Flag | Meaning |
|---|---|---|
| `claude` | `--max-budget-usd <n>` | hard USD cap |
| `claude` | `--max-turns <n>` | reasoning/tool turn cap |
| `grok` | `--max-turns <n>` | turn cap |
| `command-code` | `--max-turns <n>` | turn cap (exit code `8` when hit) |
| `agy` | `--print-timeout <3m>` | print-mode timeout |
| `cline` | `-t, --timeout <s>` | process timeout |
| `cline` | `--retries <n>` | max consecutive-error retries |
| `droid` | `--auto <level>` | autonomy tiers (indirect risk limit) |
| all | OS-level timeout via the `TO` helper | universal backstop (`exit 124`) |

## 6. Session / ephemeral (keep CI clean)

| CLI | Flag | CLI | Flag |
|---|---|---|---|
| `claude` | `--no-session-persistence` | `kilo` | auto (per UUID) |
| `codex` | `--ephemeral` | `mimo` | auto (per UUID) |
| `pi` | `--no-session` | `amp` | thread archive |
| `omp` | `--no-session` | `cline` | auto cleanup |
| `command-code` | `--no-session` | `cursor-agent` | auto |
| `opencode` | auto (per UUID) | `droid` | auto cleanup |

## 7. Tool allow / deny (security perimeter)

| CLI | Allow | Deny |
|---|---|---|
| `claude` | `--allowedTools "Read" "Grep" "Glob" "Edit" ...` | `--disallowedTools "Bash(rm *)" "Bash(sudo *)" "Bash(git push --force*)" "Bash(cat *.env*)" "mcp__*"` |
| `codex` | `-s workspace-write` (policy) | `-s read-only` (policy) |
| `pi` | `--tools read,grep,find,ls` | `--exclude-tools bash` |
| `omp` | `--tools ...` | `--no-lsp --no-pty` (capability) |
| `grok` | `--allow "RULE"` | `--deny "Bash(rm *)"` |
| `copilot` | `--allow-all-tools`, `--allow-all-paths` | omit them; `--plan` for read-only |
| `droid` | `--enabled-tools ApplyPatch` | `--disabled-tools execute-cli` |
| `command-code` | `--tools-all`, `--tools-enable <names>` | omit; use `--max-turns` |
| `cursor-agent` | `--force` (approve) | `--sandbox enabled` (policy) |

## 8. Isolated git worktree (safe write mode)

| CLI | Flag |
|---|---|
| `droid` | `-w, --worktree [name]` |
| `cursor-agent` | `-w, --worktree [name]` |
| `command-code` | `-w, --worktree <name>` |
| `grok` | `-w, --worktree [name]` |
| all others | create one in the wrapper: `git worktree add -b <branch> "$TMP" HEAD` |

## 9. Model selection

| CLI | Flag | CLI | Flag |
|---|---|---|---|
| `claude` | `--model` | `opencode` | `-m <provider/model>` |
| `codex` | `-m, --model` | `kilo` | `-m <provider/model>` |
| `agy` | `--model` | `mimo` | `-m <provider/model>` |
| `grok` | `-m, --model` | `cline` | `-m, --model` (+ `-P --provider`) |
| `pi` | `--model` | `droid` | `-m, --model` (+ `--worker-model`, `--validator-model`) |
| `omp` | `--model` / `--smol` / `--slow` / `--plan` | `amp` | `-m, --mode smart\|rush\|deep\|free` |
| `cursor-agent` | `--model` | `copilot` | `--model` |

## 10. Server / ACP daemon

| CLI | Daemon | Client attach |
|---|---|---|
| `opencode` | `opencode serve --port <p> --hostname 0.0.0.0` | `opencode run --attach <url>` |
| `kilo` | `kilo serve --port <p>` | `kilo run --attach <url>` |
| `mimo` | `mimo serve --port <p>` | `mimo attach <url>` |
| ACP server | `omp acp`, `opencode acp`, `mimo acp`, `kilo acp`, `copilot --acp`, `cline --acp`, `agy remote-control`, `codex app-server` | — |

## 11. Recommended presets by scenario

| Scenario | Preset |
|---|---|
| Read-only triage / review | one-shot + read-only + json, low timeout: `codex exec --sandbox read-only --json` / `claude -p` with `--allowedTools Read,Grep,Glob` |
| Second opinion (other vendor) | `grok -p --permission-mode dontAsk --output-format json` or `cursor-agent -p --plan --output-format json` |
| Huge-context scan | `agy -p --mode plan --output-format json` |
| Fast micro-fix | `pi -p --mode json --no-session --tools read,edit,write` |
| Guarded auto-fix (isolated write) | `droid exec --auto medium --output-format json` or `command-code -p --auto-accept -w <name>` |
| Cost-optimized repo work | `omp -p --plan-yolo --plan-yolo-into <cheap-model>` |
| Strict turn control | `command-code -p --auto-accept --max-turns 15` (watch `exit 8`) |
| Multi-agent validation | `droid exec --mission --auto high --validator-model <model>` |

## 12. Recommended models by CLI (summary)

Fast/cheap vs default vs strongest. Full detail (tiers + the provider / model-id list) lives in
each `references/<binary>/models.md`.

| CLI | Fast / cheap | Default | Strongest | List models with |
|---|---|---|---|---|
| `claude` | `haiku` | `sonnet` | `opus` | aliases in `claude --help` |
| `codex` | `gpt-5.4-mini` | `gpt-5.4` | newest `gpt-5.6-*` / `gpt-6-*` | `-m` (`o3` also ok) |
| `agy` | `...-flash` | mid `...-pro-*` | largest Pro + `--effort high` | `--model` |
| `grok` | (unset) | account default | pinned model | `-m, --model` |
| `copilot` | a `-mini` variant | `gpt-5.4` | newest flagship | `--model`, `auto` |
| `pi` | `claude-haiku-4.5` / `gpt-5.4-mini` | `claude-sonnet-5` | `claude-opus-5` | `pi --list-models` |
| `omp` | `--smol haiku` | `--model sonnet` | `--slow opus` | roles + fuzzy |
| `opencode` | a `*-free` model | provider `.../sonnet` | provider `.../opus` | `opencode models` |
| `kilo` | `kilo/anthropic/claude-haiku-4.5` | `kilo/anthropic/claude-sonnet-5` | `kilo/anthropic/claude-opus-5` | `kilo models` |
| `mimo` | `xiaomi/mimo-v2.5-pro-ultraspeed` | `xiaomi/mimo-v2.5` | `xiaomi/mimo-v2.5-pro` | `mimo models` |
| `amp` | `--mode rush` | `--mode smart` | `--mode deep` | modes = model tier |
| `cline` | a `-mini` variant | provider default | newest flagship | `-m` + `-P` |
| `command-code` | `deepseek/deepseek-v4-flash` | `deepseek/deepseek-v4-flash` | `zai-org/glm-5.3` / `qwen/qwen3.8-max` | `command-code --list-models` |
| `cursor-agent` | a `-mini`/`-fast` variant | `gpt-5` / `sonnet-4` | `sonnet-4-thinking` | `cursor-agent models` |
| `droid` | `--worker-model` (fast) | `claude-opus-4-8` | `--validator-model` (other vendor) | `-m` |

**Rule of thumb:** pick the cheapest tier that passes; escalate only for security /
high-risk work or hard cross-file reasoning. Pin the model in CI for reproducibility.

