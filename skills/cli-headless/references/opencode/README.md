# `opencode` — OpenCode

Client/server agent. Headless: `opencode run`.
Best for: client/server architecture (`serve` + `--attach`), deterministic CI runs (`--pure`).

## Invocation

```bash
TO 150 opencode run "<PROMPT>" \
  --pure --auto --format json 2>/dev/null
```

## Key flags

| Flag | Purpose |
|---|---|
| `run` | one-shot headless subcommand |
| `--pure` | don't load external plugins (deterministic) |
| `--auto` | auto-approve non-denied permissions |
| `--format default\|json` | structured output |
| `-m, --model <provider/model>` | model select |
| `-f, --file` | attach files |
| `--attach <url>` | attach to a running `opencode serve` |
| `--variant` | provider-specific reasoning effort |

## Output / parsing

- `--format json` → JSON event stream (`session_created`, `tool_start`, `message`,
  `session_complete`).
- Long prompt via stdin: `cat ctx.txt | opencode run --pure --auto --format json "<PROMPT>"`.

## Notes

- Server model: `opencode serve --port 4096 --hostname 0.0.0.0` then `--attach`.
- `opencode pr <number>` fetches a PR branch, works, and commits back.


## Recommended models

Recommended tiers and the full model-id / provider list: see [models.md](models.md).
