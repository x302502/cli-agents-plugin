# `omp` — Oh My Pi (Can Bölük / Stencil)

Rust-native core with LSP/DAP; shares its runtime and JSON event schema with `pi`.
Headless: `omp -p`.
Best for: large codebases needing type/LSP awareness, and plan→execute cost optimization.

Verified against **`omp v18.2.1`** (smoke: exit 0 in ~4.5 s, both plain and `--plan-yolo`).

## Invocation

```bash
TO 180 omp -p "<PROMPT>" \
  --no-session --no-lsp --no-pty --mode json 2>/dev/null
```

Cost-optimized variant — read-only plan first, then a cheaper model implements it:

```bash
TO 180 omp -p "<PROMPT>" \
  --plan-yolo --plan-yolo-into claude-haiku \
  --no-session --no-lsp --no-pty --mode json 2>/dev/null
```

## Key flags

| Flag | Purpose |
|---|---|
| `-p, --print` | non-interactive: process the prompt and exit |
| `--mode text\|json\|rpc\|rpc-ui` | output mode (`json` = NDJSON event stream) |
| `--plan-yolo` | force read-only plan mode, auto-approve the plan, then switch model to implement |
| `--plan-yolo-into <model>` | executor model for plan-yolo (default: the `smol` role) |
| `--prewalk` / `--prewalk-into <model>` | switch to a cheap model at the first edit/write once the plan's todo list exists |
| `--auto-approve` | auto-approve all tool calls (**write mode**) |
| `--approval-mode always-ask\|write\|yolo` | override the approval policy for this session |
| `--tools <a,b,c>` / `--no-tools` | tool allowlist / disable all built-in tools (**read-only mode**). Valid names: `read,grep,glob,write,goal,init_experiment,run_experiment,log_experiment,update_notes` |
| `--no-lsp` | skip language servers (fast CI startup) |
| `--no-pty` | avoid PTY-based interactive bash (CI-safe) |
| `--no-session` | ephemeral — don't save the session |
| `-c, --continue` / `-r, --resume <id>` | reuse a previous session |
| `--model <fuzzy>` | fuzzy match: `opus`, `gpt-5.2`, or `openai/gpt-5.2` |
| `--smol` / `--slow` / `--plan` | role models (env: `PI_SMOL_MODEL`, `PI_SLOW_MODEL`, `PI_PLAN_MODEL`) |
| `--thinking off\|minimal\|low\|medium\|high\|xhigh\|max\|auto` | reasoning level |
| `--max-time <600\|10m\|1h>` | stop the session after this duration |
| `--provider <value>` | legacy; prefer `--model` |
| `--cwd <dir>` / `--add-dir <dir>` | working dir / extra workspace dir |
| `omp acp` | ACP (Agent Client Protocol) server over stdio |

## Output / parsing

`--mode json` emits an **NDJSON event stream** with the same schema as `pi`:
`session`, `agent_start`, `turn_start`, `message_start`, `message_update`, `message_end`,
`turn_end`, `agent_end`. All four commands below are verified against a real run.

```bash
# final assistant text
jq -r 'select(.type=="message_end") | .message | select(.role=="assistant")
       | .content[]? | select(.type=="text") | .text' out.jsonl

# ...or from the terminal event
jq -r 'select(.type=="agent_end") | .messages[] | select(.role=="assistant")
       | .content[]? | select(.type=="text") | .text' out.jsonl

# tokens + cost
jq -c 'select(.type=="turn_end") | .message.usage
       | {totalTokens, reasoningTokens, cost: .cost.total}' out.jsonl
```

Cost also appears per message at `.message.usage.cost` (`input`, `output`, `cacheRead`,
`cacheWrite`, `total`); `duration`/`ttft` are reported on the final `message_end`.

## Notes

- `--plan-yolo` + `--plan-yolo-into <cheap-model>` is the headline cost-saver; `--prewalk` is
  the lighter-weight version of the same idea.
- **Read-only**: omit `--auto-approve` and pin `--tools read,grep,glob`.
- **Write** (plugin default): add `--auto-approve`, or `--approval-mode yolo`.
- ⚠️ **omp's tool names differ from `pi`** even though they share a core. `omp v18.2.1` accepts
  exactly: `read, grep, glob, write, goal, init_experiment, run_experiment, log_experiment,
  update_notes`. There is **no** `find`, `ls`, `edit`, or `bash` — passing them fails with
  `CliUsageError: Unknown tool in --tools: <name>` (exit 1). `pi` *does* accept `find`/`ls`,
  so never copy pi's allowlist across.
- `omp cleanse --no-session` auto-fixes project diagnostics with weighted parallel subagents.
- `omp models` lists every provider/model with context, max-out, thinking levels, image support.
- `omp ps` lists/controls daemon-supervised background processes; `omp usage` shows provider limits.

## Recommended models

Recommended tiers and the full model-id / provider list: see [models.md](models.md).
