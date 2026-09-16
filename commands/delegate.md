---
description: Delegate a task to another installed CLI agent via the cli-delegate subagent
argument-hint: "<cli> <task...> [--background|--wait] [--read-only] [--model <id>]"
allowed-tools: Bash, Read, Glob, Grep, Agent, AskUserQuestion
---

Delegate the request to the `cli-agents:cli-delegate` subagent.

Raw request:
$ARGUMENTS

## 1. Resolve the CLI — ASK if it is missing

A CLI is "given" only if `$ARGUMENTS` starts with a known binary name
(`agy|claude|cline|codex|grok|opencode|pi`)
or contains `--cli <name>`.

If no CLI is given, do NOT guess and do NOT delegate yet:
- Run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-setup.sh"` to see which CLIs are installed.
- Use `AskUserQuestion` **exactly once** to ask which CLI to use. Offer 2–4 installed CLIs as
  options, with a sensible default first, suffixed `(Recommended)`: prefer `codex`, else
  `claude`, else `grok`, else any installed one.
- Use the chosen CLI for the delegation.

## 2. Resolve the model — ASK (CLI default vs pick)

If the user did not pass `--model <id>`, ask once with `AskUserQuestion`:
- **Use the CLI's own default model (Recommended)** → do NOT pass any model flag; the CLI
  keeps whatever model it is configured with.
- **Pick a model** → read `skills/cli-headless/references/<cli>/models.md` and offer 2–4
  options (fast / default / strongest) as choices, then pass the CLI's model flag
  (`--model <id>` or `-m <id>`).

Skip this question entirely when `--model` is already present.

## 3. Resolve the task — ASK if it is missing

If there is no task text after the CLI (or `$ARGUMENTS` is empty), use `AskUserQuestion`
once to ask what the CLI should do. Never invent a task.

### Prompt template reuse

If the task is clearly a **refactor** or a **triage/diagnosis** request, base the delegated
prompt on the matching template — fill `{{TARGET_LABEL}}` (what to act on) and
`{{USER_FOCUS}}` (the user's goal / symptom), then pass the filled template as the task text:

- refactor → `prompts/refactor.md`
- triage / root-cause → `prompts/triage.md`

Otherwise pass the user's task text verbatim.

## 4. Delegate

Invoke the `cli-agents:cli-delegate` subagent via the `Agent` tool
(`subagent_type: "cli-agents:cli-delegate"`), passing the resolved CLI + task and any flags.
`cli-delegate` is a subagent, not a skill — do not call `Skill(...)` for it.

Routing flags (strip them from the task text):
- `--background` — run detached: the subagent launches the CLI via
  `bash "${CLAUDE_PLUGIN_ROOT}/scripts/jobs.sh" start -- "<command>"` and returns the job id.
  Then tell the user to check `/cli-agents:status`.
- `--wait` — run in the foreground (default).
- `--read-only` — force read-only. **Default is auto-write**: the CLI may edit files and run
  commands so it completes the task, then reports every file changed.
- `--model <id>` — pin the model.

Return the subagent's `## CLI delegation report` verbatim. Never fix anything it reports.