# `grok` — Grok Build (xAI)

Headless: `grok -p` (alias `--single`).
Best for: xAI models, realtime-info tasks, security review, streaming JSON.

## Invocation

```bash
TO 150 grok -p "<PROMPT>" \
  --permission-mode dontAsk \
  --output-format json --max-turns 12 \
  --deny "Bash(rm *)" 2>/dev/null
```

## Key flags

| Flag | Purpose |
|---|---|
| `-p, --single` | one-shot headless prompt |
| `-m, --model` | model select |
| `--permission-mode dontAsk` / `--always-approve` | auto-approve behavior |
| `--allow` / `--deny <rule>` | tool allow/deny rules |
| `--output-format json\|streaming-json` | structured output |
| `--json-schema <schema>` | enforce structured output (implies `json`) |
| `--max-turns <n>` | turn cap |
| `-w, --worktree [name]` | isolated git worktree (note: `-p` does not use it) |

## Output / parsing

- `--output-format json` → validated JSON object.
- `streaming-json` (a.k.a. `streaming-messages-json`) → NDJSON; add
  `--include-partial-messages` for text/thinking deltas.

## Notes

- Real **worktree isolation does not apply in `-p` mode** — create a worktree in the wrapper
  if needed.


## Recommended models

Recommended tiers and the full model-id / provider list: see [models.md](models.md).
