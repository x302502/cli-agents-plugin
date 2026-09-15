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
  with a sensible default first suffixed `(Recommended)`: prefer `codex`, else `claude`.

## 2. Resolve the model — ASK (CLI default vs pick)

If `$ARGUMENTS` has no `--model <id>`, ask once with `AskUserQuestion`:
- **Use the CLI's own default model (Recommended)** → pass no model flag.
- **Pick a model** → read `skills/cli-headless/references/<cli>/models.md` and offer 2–4
  options (fast / default / strongest), then pass the CLI's model flag.

Skip the question when `--model` is already present.

## 3. Review

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