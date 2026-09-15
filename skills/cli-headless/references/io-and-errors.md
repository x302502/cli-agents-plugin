# Output Parsing, Report Schema & Error Handling

## Output Handling & Parsing

1. **Check the exit code first.** `124` = timeout; non-zero = failure. If stderr was
   suppressed and the run failed, re-run capturing `2>&1 | tail -30` for diagnosis.
2. **Parse structured output** with `jq` (available at `/usr/bin/jq`):
   - codex: the `--json` stream ends with `item.completed` (`agent_message.text`); `-o <file>`
     holds just the final message.
   - pi: NDJSON event stream — take the last assistant text:
     `jq -r 'select(.type=="message_end" and .message.role=="assistant") | .message.content[]? | select(.type=="text") | .text'`
     (pi's final `agent_settled` event carries no text).
   - opencode: tail the `session_complete` / result event line.
   - agy / grok / cline: parse the `--output-format json` / `--json` payload with `jq`;
     for free text, read the rendered message directly.
3. **De-duplicate noise.** If a CLI leaks loading/banner text, strip it. Save the raw log
   to a temp file and reference it instead of pasting everything.
4. **Summarize for the parent.** If the parent wanted a short answer, extract the key
   findings; keep tables/lists in their original shape.

---

## Return To Main — Report Schema

Always answer with this block, then the delegated result beneath it:

```markdown
## CLI delegation report
- **CLI:** <binary> <model/mode flags actually used>
- **Task:** <one-line restatement>
- **Command:** `<the exact command, prompt truncated to ~120 chars>`
- **Status:** SUCCESS | FAILED | TIMEOUT | PARTIAL
- **Exit code:** <n>  |  **Duration:** <s>s  |  **Cost:** <usd or "n/a">
- **Artifacts:** <files created/changed, or "none">
- **Raw output:** <path to saved raw log, or "inline">
- **Warnings:** <permission denials, schema mismatches, truncated output>

### Result
<cleaned summary / structured output from the CLI>
```

**Machine-readable twin:** `schemas/delegation-report.schema.json` (validate with
`jq -e` or any JSON-Schema validator if needed). Field mapping for the block above:
`CLI→cli`, `Task→task`, `Command→command`, `Status→status`, `Exit code→exit_code`,
`Duration→duration_sec`, `Cost→cost_usd`, `Artifacts→artifacts`,
`Raw output→raw_output`, `Warnings→warnings`, `Result→result`.
Every field is required — use `"n/a"` when a value genuinely does not apply.

---

## Error Handling & Fallback

| Symptom | Cause | Action |
|---|---|---|
| Process hangs forever | missing non-interactive/auto-approve flag | re-run with `-p`/`--auto`/`dontAsk` and full tool allow-list |
| `TIMEOUT` (exit 124) | task too big / CLI slow | narrow scope, raise timeout, or pick a faster CLI |
| `structured_output` null | output didn't match schema | loosen `required`, restate the schema rule in the prompt |
| CLI stops asking permission | auto-approve flag missing | add the CLI's yolo/auto/dontAsk flag |
| `command not found` | CLI not installed | report "CLI not available" and suggest an alternative from the matrix |
| budget/turn cap hit | task too large | report and suggest a higher cap or splitting the task |

## Failure classification (run on every non-OK run)

Always capture the run to a log file, then classify it **before** reporting:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-run.sh" <log-file> <exit-code>
```

| TYPE | Meaning | Action |
|---|---|---|
| `OK` | success | parse the output |
| `TIMEOUT` (124) | too slow / too big | narrow scope, raise timeout, or use a faster CLI |
| `CLI_MISSING` (127) | binary not installed | pick another CLI or install it |
| `AUTH` | not logged in / bad key | authenticate (`codex login`, `agent login`, run once interactively) |
| `RATE_LIMIT` | 429 / quota | back off, retry later, or switch CLI/model |
| `BAD_FLAGS` | wrong/invalid flag | re-check the recipe against `<cli> --help` |
| `CONTEXT_OVERFLOW` | input too large | scope the input (fewer files, tail logs) |
| `PERMISSION` | sandbox / approval blocked | add the missing auto-approve flag (or `--trust`) |
| `NONZERO_EXIT` | generic failure | inspect the log tail; retry once, then switch CLI |
| `EMPTY_OUTPUT` | no output | narrow the prompt or switch CLI |

Rules:
- Put the `TYPE` in the report's **Warnings** and set **Status** to `FAILED` / `TIMEOUT`.
- Retry **at most once** (raise the timeout on `TIMEOUT`; add the flag on `PERMISSION`).
- On `CLI_MISSING` / `AUTH` / `RATE_LIMIT`, **switch CLI** instead of retrying.
- Never invent a result to hide a failure.

**If the chosen CLI is unavailable or repeatedly fails:** do NOT attempt to solve the task
yourself (you are Haiku, not suited for deep work). Pick another installed CLI, or return the
failure plus its classification to the parent.

---
