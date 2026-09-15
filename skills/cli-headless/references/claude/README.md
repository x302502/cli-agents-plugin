# `claude` — Claude Code (Anthropic)

Host CLI and the strongest general reasoner in the set. Headless: `claude -p`.
Best for: highest-stakes reasoning, cross-file correctness, enforced JSON-schema output, and a
peer/second-opinion pass.

## Invocation

```bash
TO 150 claude -p "<PROMPT>" \
  --permission-mode dontAsk \
  --allowedTools "Read" "Grep" "Glob" "Edit" "Write" "Bash" \
  --disallowedTools "Bash(rm *)" "Bash(sudo *)" "Bash(docker *)" "Bash(git push --force*)" "Bash(cat *.env*)" \
  --max-budget-usd 1.00 --max-turns 20 \
  --no-session-persistence \
  --output-format json 2>/dev/null
```

Read-only: allow only `Read Grep Glob` and omit the edit tools.

## Key flags

| Flag | Purpose |
|---|---|
| `--permission-mode dontAsk` | auto-deny anything not allow-listed (safe headless default) |
| `--allowedTools` / `--disallowedTools` | tool allow/deny boundary |
| `--max-budget-usd <n>` | hard USD cap |
| `--max-turns <n>` | reasoning/tool turn cap |
| `--json-schema <schema\|file>` | enforce structured output |
| `--output-format json\|stream-json` | machine-parseable output |
| `--no-session-persistence` | ephemeral (no session files) |
| `--bare` | skip hooks/LSP/plugins/CLAUDE.md (fast micro-tasks) |
| `--model` | model select |

## Output / parsing

- `--output-format json` → `{ result, total_cost_usd, session_id, structured_output }`.
- Extract: `jq -r '.result // .structured_output'`.
- `stream-json` = NDJSON events (`type: assistant|result`).

## Notes

- Use `--dangerously-skip-permissions` only inside isolated/sandboxed environments.
- If `--json-schema` output does not match, `structured_output` is `null`.


## Recommended models

Recommended tiers and the full model-id / provider list: see [models.md](models.md).
