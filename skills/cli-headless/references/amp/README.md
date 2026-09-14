# `amp` — Amp CLI

Headless: `amp -x` / `--execute`. Output is Claude-Code-compatible stream-json.
Best for: stream-json pipelines, quick micro-fixes, deep reasoning mode.

## Invocation

```bash
TO 150 amp -x "<PROMPT>" \
  --mode smart --no-color \
  --stream-json 2>/dev/null
```

## Key flags

| Flag | Purpose |
|---|---|
| `-x, --execute [message]` | one-shot headless |
| `-m, --mode smart\|rush\|deep\|free` | agent mode (quality/speed tradeoff) |
| `--stream-json` | Claude-Code-compatible NDJSON |
| `--stream-json-thinking` | include thinking blocks |
| `--stream-json-input` | push JSON Lines user messages via stdin |
| `--dangerously-skip-permissions` | auto-approve all commands (trusted) |
| `--no-color` | clean output for pipes |

## Output / parsing

- `--stream-json` → NDJSON. Extract assistant text:
  ```bash
  jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text'
  ```

## Notes

- Redirection is equivalent to `-x`: `amp < prompt.txt > result.txt`.
- Add `--no-color` whenever piping to `jq`.


## Recommended models

Recommended tiers and the full model-id / provider list: see [models.md](models.md).
