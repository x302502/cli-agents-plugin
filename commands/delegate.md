---
description: Delegate a task to another installed CLI agent via the cli-delegate subagent
argument-hint: "<cli> <task...> [--background|--wait] [--write] [--model <id>]"
allowed-tools: Bash, Read, Glob, Grep, Agent
---

Invoke the `cli-agents:cli-delegate` subagent via the `Agent` tool
(`subagent_type: "cli-agents:cli-delegate"`), forwarding the raw request. It is a subagent,
not a skill — do not call `Skill(...)` for it.

Raw request:
$ARGUMENTS

Routing flags (strip them from the task text):
- `--background` — run detached: the subagent launches the CLI via
  `bash "${CLAUDE_PLUGIN_ROOT}/scripts/jobs.sh" start -- "<command>"` and returns the job id.
  Then tell the user to check `/cli-agents:status`.
- `--wait` — run in the foreground (default).
- `--write` — authorize edits (default is read-only).
- `--model <id>` — pin the model.

Return the subagent's `## CLI delegation report` verbatim. Never fix anything it reports.