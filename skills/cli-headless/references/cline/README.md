# `cline` — Cline CLI

Headless by default with auto-approve on. Headless: `cline "<prompt>"`.
Best for: zero-config automation with built-in timeout/retries.

## Invocation

```bash
TO 120 cline "<PROMPT>" \
  --json --timeout 120 --retries 3 2>/dev/null
```

## Key flags

| Flag | Purpose |
|---|---|
| `cline "<prompt>"` | runs headless + `auto-approve true` by default |
| `--json` | output a message array (vs styled text) |
| `-t, --timeout <seconds>` | process timeout |
| `--retries <n>` | max consecutive-error retries |
| `-p, --plan` | read-only planning mode |
| `-m, --model <model-id>` / `-P, --provider <id>` | model select |
| `--compaction agentic\|basic\|off` | context compaction |
| `-i, --tui` | interactive TUI (do NOT use in headless) |

## Output / parsing

- `--json` → array of `{ role, content }`; extract assistant text:
  ```bash
  jq -r '.[] | select(.role=="assistant") | .content'
  ```

## Notes

- Never pass `-i` in automation — it opens the TUI and hangs.


## Recommended models

Recommended tiers and the full model-id / provider list: see [models.md](models.md).
