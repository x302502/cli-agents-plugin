# `copilot` — GitHub Copilot CLI (GitHub)

Headless: `copilot -p`.
Best for: GitHub/GitHub-Actions-centric flows, JSDoc/doc sweeps, usage telemetry.

## Invocation

```bash
TO 150 copilot -p "<PROMPT>" \
  --allow-all-tools \
  --output-format json \
  --usage-output-file /tmp/copilot-usage.json 2>/dev/null
```

Read-only analysis: use `--plan` and omit `--allow-all-tools`.

## Key flags

| Flag | Purpose |
|---|---|
| `-p, --prompt <text>` | non-interactive prompt |
| `--allow-all-tools` | auto-approve tools |
| `--allow-all-paths` | allow file access outside default scope |
| `--allow-all` / `--yolo` | tools + paths + URLs |
| `--plan` | start in read-only plan mode |
| `--output-format json` | JSONL event stream |
| `--usage-output-file <file>` | token/usage stats as JSON |
| `--model` | model select |
| `--acp` | run as ACP server |

## Output / parsing

- `--output-format json` → JSONL; parse the event lines.
- `--usage-output-file` → `{ total_tokens, prompt_tokens, completion_tokens, model, tools_executed }`.

## Notes

- `--yolo` also grants path + URL access — use only in trusted setups.
- Missing `--allow-all-tools` makes the run hang on a permission prompt.


## Recommended models

Recommended tiers and the full model-id / provider list: see [models.md](models.md).
