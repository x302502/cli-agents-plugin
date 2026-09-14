# `command-code` — Command Code

Taste-learning agent. Headless: `command-code -p`.
Best for: style-consistent output, strict turn caps, isolated worktrees.

## Invocation

```bash
TO 150 command-code -p "<PROMPT>" \
  --auto-accept --skip-onboarding --no-session \
  --max-turns 15 --output-format json 2>/dev/null
```

## Key flags

| Flag | Purpose |
|---|---|
| `-p, --print [query]` | non-interactive |
| `--auto-accept` / `--yolo` | auto-approve edits + commands |
| `--skip-onboarding` | bypass the Taste Learning screen (required first/CI run) |
| `--no-session` | in-memory only |
| `--max-turns <n>` | turn cap → **exit code 8** when hit |
| `--output-format text\|json` | NDJSON events + final result line |
| `-w, --worktree <name>` | managed git worktree |
| `--tools-all` / `--tools-enable <names>` | tool control |

## Output / parsing

- `--output-format json` → NDJSON (`start`, `tool_call`, `tool_result`, `result`).

## Notes

- Always pass `--skip-onboarding` on CI or it hangs on the onboarding screen.
- On `exit 8`, report it and suggest a higher `--max-turns` or a smaller task.


## Recommended models

Recommended tiers and the full model-id / provider list: see [models.md](models.md).
