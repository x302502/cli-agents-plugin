# `pi` — Pi Coding Agent (Mario Zechner)

Minimal, fastest-startup agent (<0.5s). Headless: `pi -p`.
Best for: micro-tasks, batch loops, RPC, and when startup latency matters.

## Invocation

```bash
TO 90 pi -p "<PROMPT>" \
  --mode json --no-session --no-context-files \
  --tools read,grep,find,ls 2>/dev/null
```

Write task: `--tools read,edit,write` (add `bash` only if tests must run).

## Key flags

| Flag | Purpose |
|---|---|
| `-p, --print` | non-interactive |
| `--mode text\|json\|rpc` | output mode |
| `--no-session` | ephemeral |
| `--no-context-files` | skip AGENTS.md / CLAUDE.md |
| `--no-skills` / `--no-extensions` | disable discovery |
| `--tools <csv>` / `--exclude-tools <csv>` | tool allow/deny (deny shell: `--exclude-tools bash`) |
| `--thinking <off\|low\|medium\|high\|...>` | reasoning level |
| `--model <provider/id>` | model select |

## Output / parsing

- `--mode json` emits an **NDJSON event stream** (`session`, `message_start/update/end`,
  `agent_end`, `agent_settled`). Final text:
  ```bash
  jq -r 'select(.type=="message_end" and .message.role=="assistant") | .message.content[]? | select(.type=="text") | .text'
  ```
- `agent_settled` carries no text.

## Notes

- `@file` attachments supported: `pi -p @tsconfig.json "<PROMPT>"`.
- Safe CI: `--no-session --no-context-files --no-skills`.


## Recommended models

Recommended tiers and the full model-id / provider list: see [models.md](models.md).
