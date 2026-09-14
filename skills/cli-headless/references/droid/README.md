# `droid` — Factory Droid (Factory AI)

Multi-agent enterprise agent. Headless: `droid exec`.
Best for: multi-agent missions with cross-validation, and tiered autonomy by environment.

## Invocation

```bash
TO 180 droid exec "<PROMPT>" \
  --auto medium \
  --output-format json 2>/dev/null
```

## Key flags

| Flag | Purpose |
|---|---|
| `exec [prompt]` | non-interactive subcommand |
| `--auto low\|medium\|high` | autonomy tier (dev / staging / prod) |
| `--mission` | multi-agent mission (needs `--auto high` or `--skip-permissions-unsafe`) |
| `--model` / `--worker-model` / `--validator-model` | mission model roles |
| `--output-format text\|json` | output format |
| `-w, --worktree [name]` | isolated git worktree |
| `-f, --file <path>` | read prompt from a file |
| `--enabled-tools` / `--disabled-tools` | tool control |
| `--skip-permissions-unsafe` | bypass all checks (containers only) |

## Output / parsing

- `json` → `{ mission_status, autonomy_level, worker_model, validator_model, validation_passed, summary }`.

## Notes

- `--auto low` = safe file ops; `medium` = deps/tests/edits; `high` = commit/push (avoid unless authorized).
- `--skip-permissions-unsafe` cannot be combined with `--auto`.


## Recommended models

Recommended tiers and the full model-id / provider list: see [models.md](models.md).
