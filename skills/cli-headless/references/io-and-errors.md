# Output Parsing, Report Schema & Error Handling

## Output Handling & Parsing

1. **Check the exit code first.** `124` = timeout; `8` (command-code) = turn cap hit;
   non-zero = failure. If stderr was suppressed and the run failed, re-run capturing
   `2>&1 | tail -30` for diagnosis.
2. **Parse structured output** with `jq` (available at `/usr/bin/jq`):
   - claude: `jq -r '.result // .structured_output'`
   - codex: the `--json` stream ends with `item.completed` (`agent_message.text`); `-o <file>`
     holds just the final message.
   - amp: `jq -r 'select(.type=="assistant") | .message.content[]? | select(.type=="text") | .text'`
   - copilot: parse the JSONL stream; read the `--usage-output-file` for token stats.
   - pi / omp: NDJSON event stream — take the last assistant text:
     `jq -r 'select(.type=="message_end" and .message.role=="assistant") | .message.content[]? | select(.type=="text") | .text'`
     (pi's final `agent_settled` event carries no text).
   - opencode / kilo / mimo: tail the `session_complete` / result event line.
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

**If the chosen CLI is unavailable or repeatedly fails:** do NOT attempt to solve the task
yourself (you are Haiku, not suited for deep work). Pick another CLI from the matrix that
is installed, or return the failure to the parent with a clear recommendation.

---
