# `kilo` — Kilocode CLI

Cloud/local worker (OpenCode-shaped). Headless: `kilo run`.
Best for: refactor batches, CI workers, PR automation.

## Invocation

```bash
TO 150 kilo run "<PROMPT>" \
  --auto --pure --format json 2>/dev/null
```

## Key flags

| Flag | Purpose |
|---|---|
| `run` | one-shot headless subcommand |
| `--auto` | auto-approve all permissions |
| `--dangerously-skip-permissions` | auto-approve non-denied permissions |
| `--pure` | don't load external plugins |
| `--format default\|json` | structured output |
| `-m, --model <provider/model>` | model select |
| `-f, --file` | attach files |
| `--attach <url>` | attach to a running `kilo serve` |

## Output / parsing

- `--format json` → JSON event stream; tail the `session_complete` line.

## Notes

- Server model: `kilo serve --port 4096 --hostname 0.0.0.0` then `--attach`.
- `kilo pr <number>` fetches a PR branch, works, and commits back.


## Recommended models

Recommended tiers and the full model-id / provider list: see [models.md](models.md).
