# `cursor-agent` — Cursor Agent CLI (Cursor)

Headless: `cursor-agent -p`.
Best for: Cursor models, sandboxed edits, private cloud worker.

## Invocation

```bash
TO 150 cursor-agent -p "<PROMPT>" \
  --force --trust --sandbox enabled \
  --output-format json 2>/dev/null
```

## Key flags

| Flag | Purpose |
|---|---|
| `-p, --print` | non-interactive |
| `-f, --force` / `--yolo` | auto-approve (Except explicitly denied) |
| `--trust` | trust the workspace without prompting |
| `--sandbox enabled\|disabled` | shell sandbox |
| `--output-format text\|json\|stream-json` | output format |
| `--plan` / `--mode plan\|ask` | read-only planning / Q&A |
| `-w, --worktree [name]` | isolated worktree in `~/.cursor/worktrees/` |
| `--api-key` / `CURSOR_API_KEY` | auth |

## Output / parsing

- `json` → `{ status, files_modified, tools_used, summary }`.
- `stream-json` → realtime NDJSON; add `--stream-partial-output` for deltas.

## Notes

- Missing `--trust` on a fresh runner stops to ask workspace trust.
- `cursor-agent worker` turns the machine into a private cloud worker.


## Recommended models

Recommended tiers and the full model-id / provider list: see [models.md](models.md).
