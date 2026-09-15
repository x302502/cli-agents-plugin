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
- ⚠️ **Provider dependency:** if `opencode.json` points at a local gateway
  (e.g. `http://127.0.0.1:23333/v1` — cherry-gateway), one-shot runs fail with
  `APIError: Cannot connect to API` when that server is down. Verify with
  `curl -m 3 http://127.0.0.1:23333/` and start the gateway first, or switch the
  provider in `opencode.json` to a hosted one. Classified as `NONZERO_EXIT` by
  `check-run.sh`.


## Recommended models

Recommended tiers and the full model-id / provider list: see [models.md](models.md).
