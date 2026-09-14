# `codex` — Codex CLI (OpenAI)

Sandboxed OpenAI agent (o-series / gpt-5). Headless: `codex exec`.
Best for: sandboxed code work, read-only triage, PR/branch review.

## Invocation

```bash
TO 150 codex exec "<PROMPT>" \
  --sandbox read-only \
  --ephemeral --skip-git-repo-check \
  --json -o /tmp/codex-last.txt 2>/dev/null
```

Use `--sandbox workspace-write` to allow edits inside the repo.

## Key flags

| Flag | Purpose |
|---|---|
| `-s, --sandbox read-only\|workspace-write` | filesystem/exec policy |
| `--ephemeral` | don't persist the session |
| `--skip-git-repo-check` | run outside a git repo |
| `--json` | JSONL event stream |
| `-o, --output-last-message <file>` | write only the final message |
| `--output-schema <file>` | enforce JSON schema |
| `--dangerously-bypass-approvals-and-sandbox` | disable all guards (isolated use only) |
| `-m, --model` | model select |

## Output / parsing

- `--json` stream ends with `item.completed` → `agent_message.text`.
- `-o <file>` holds just the final message.
- Long input via stdin: `cat log.txt | codex exec - --sandbox read-only "<PROMPT>"`.

## Notes

- `codex exec review` is a ready-made PR/branch review subcommand.
- `codex exec resume <session-id> "<PROMPT>"` continues a non-ephemeral session.


## Recommended models

Recommended tiers and the full model-id / provider list: see [models.md](models.md).
