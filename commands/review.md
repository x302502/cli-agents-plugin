---
description: Read-only review of local git state via an external CLI agent
argument-hint: "[--cli <name>] [--base <ref>] [--adversarial] [--background]"
allowed-tools: Bash, Read, Glob, Grep, Agent
---

Run a READ-ONLY review by delegating to `cli-agents:cli-delegate`.

Defaults:
- CLI: `codex` if installed, else `claude`, else `grok` or `cursor-agent`.
- Target: the working tree; with `--base <ref>`, review `<ref>...HEAD`.
- Prompt: `prompts/review.md`; with `--adversarial`, `prompts/adversarial-review.md`.
- Output must conform to `schemas/review-output.schema.json`.

Hard constraints:
- Read-only: never enable edits; use the CLI's read-only / sandbox / plan mode.
- Foreground unless `--background` (then use `jobs.sh start`).
- Return the result verbatim; after presenting findings, STOP and ask what to fix.

Raw arguments:
$ARGUMENTS