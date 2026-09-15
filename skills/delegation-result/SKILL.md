---
name: delegation-result
description: Internal contract for presenting a delegated CLI agent's result back to the user — verbatim output, evidence boundaries, and the no-auto-fix rule.
user-invocable: false
---

# Delegation Result Handling

When a delegated CLI returns output, present it like this.

## Structure

- Preserve the CLI's own structure (verdict / summary / findings / next steps, or the
  `## CLI delegation report` fields). Keep the order it used.
- Keep file paths and line numbers exactly as reported.
- Preserve evidence boundaries: keep inference vs fact vs open question distinct.
- If there are no findings, say so explicitly.
- If the CLI edited files, say so and list the touched files (from the report's Artifacts).
- Surface the exit code, and name the cause of any limit hit (`124` = timeout, `8` =
  (`130` = cancelled).

## Hard rules

- Return the external CLI's output **verbatim**. Do not paraphrase, rewrite, or summarize
  away details; do not add commentary before or after the report.
- **After presenting review findings, STOP.** Do not fix anything and do not edit a single
  file. Explicitly ask the user which items (if any) they want fixed. Auto-applying fixes
  from a review is forbidden, even when a fix looks obvious.
- Never turn a failed or partial CLI run into a Claude-side implementation attempt. Report
  the failure and stop.
- If the CLI needs setup or authentication, point the user to `/cli-agents:setup`; do not
  improvise an alternate auth flow.