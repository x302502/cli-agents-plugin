---
description: Read-only review of local git state via an external CLI agent
argument-hint: "[--cli <name>] [--base <ref>] [--adversarial] [--background]"
allowed-tools: Bash, Read, Glob, Grep, Agent, AskUserQuestion
---

Run a READ-ONLY review by delegating to `cli-agents:cli-delegate`.

## 1. Resolve the CLI — ASK if `--cli` is missing

If `$ARGUMENTS` has no `--cli <name>`, do NOT guess:
- Run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-setup.sh"` to list installed CLIs.
- Use `AskUserQuestion` **exactly once** to ask which CLI to use. Offer 2–4 installed CLIs,
  with a sensible default first suffixed `(Recommended)`: prefer `codex`, else `claude`, else
  `droid`.

## 2. Review

Defaults:
- Target: the working tree; with `--base <ref>`, review `<ref>...HEAD`.
- Prompt: `prompts/review.md`; with `--adversarial`, `prompts/adversarial-review.md`.
- Output must conform to `schemas/review-output.schema.json`.

Hard constraints:
- Read-only: never enable edits; use the CLI's read-only / sandbox / plan mode.
- Foreground unless `--background` (then use `jobs.sh start`).
- Return the result verbatim; after presenting findings, STOP and ask what to fix.

Raw arguments:
$ARGUMENTS