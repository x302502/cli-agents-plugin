# `agy` — Antigravity CLI (Google DeepMind)

Official successor to Gemini CLI; agentic, 1M–2M token context. Headless: `agy -p`.
Best for: huge-context analysis and bi-directional stream-json conversation.

## Invocation

```bash
TO 180 agy -p "<PROMPT>" \
  --mode plan \
  --output-format json \
  --print-timeout 3m 2>/dev/null
```

`--mode accept-edits` allows writes; `--mode plan` is read-only.

## Key flags

| Flag | Purpose |
|---|---|
| `--mode plan\|accept-edits` | read-only vs allow writes |
| `--dangerously-skip-permissions` | auto-approve all tools (isolated/CI only) |
| `--output-format json\|stream-json` | machine-parseable output |
| `--json-schema <schema\|file>` | enforce structured output |
| `--print-timeout <3m>` | print-mode timeout |
| `--input-format stream-json` | feed NDJSON turns via stdin (requires stream-json output) |
| `--effort low\|medium\|high` | reasoning effort |
| `--model` | model select |
| `--conversation <id>` / `-c` | resume |

## Output / parsing

- `--output-format json` → final object; extract with `jq`.
- `stream-json` → NDJSON (`step_start`, `tool_call`, `tool_result`, `result`).

## Notes

- `--print-timeout` defaults to 5m; raise it for large scans.
- `--input-format stream-json` requires `--output-format stream-json`.


## Recommended models

Recommended tiers and the full model-id / provider list: see [models.md](models.md).
