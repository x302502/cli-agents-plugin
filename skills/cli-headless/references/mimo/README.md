# `mimo` — Xiaomi MiMo Code

Xiaomi agent (OpenCode-shaped). Headless: `mimo run`.
Best for: Xiaomi/MiMo token plan, CI auto-fix, PR handling.

## Invocation

```bash
TO 150 mimo run "<PROMPT>" \
  --never-ask --trust --pure 2>/dev/null
```

## Key flags

| Flag | Purpose |
|---|---|
| `run` | one-shot headless subcommand |
| `--never-ask` | never block on input |
| `--trust` | skip the workspace-trust prompt |
| `--pure` | don't load external plugins |
| `--format default\|json` | structured output |
| `-m, --model <provider/model>` | model select |
| `--attach <url>` | attach to a running `mimo serve` |

## Output / parsing

- `--format json` → JSON event stream; otherwise human-readable checklist output.

## Notes

- Server mode: `mimo serve --port 5000 --hostname 0.0.0.0`.
- `mimo pr <number>` fetches a PR branch, works, and commits back.


## Recommended models

Recommended tiers and the full model-id / provider list: see [models.md](models.md).
