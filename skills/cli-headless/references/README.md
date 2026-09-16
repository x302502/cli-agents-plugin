# References Index

Each CLI has its own folder, `references/<binary>/`, containing:

- **`README.md`** — description, headless invocation, key flags, output parsing
- **`models.md`** — recommended tiers + the full provider / model-id list

## Per-CLI folders

| Binary | Folder | Headless | Best for |
|---|---|---|---|
| `claude` | `claude/` | `claude -p` | strongest reasoning; sandbox + budget + schema |
| `codex` | `codex/` | `codex exec` | sandboxed OpenAI; JSONL; PR review |
| `agy` | `agy/` | `agy -p` | 1M+ context; Gemini successor |
| `grok` | `grok/` | `grok -p` | xAI; streaming-json; json-schema |
| `pi` | `pi/` | `pi -p` | fastest startup; micro-tasks; RPC |
| `opencode` | `opencode/` | `opencode run` | client/server; ACP |
| `cline` | `cline/` | `cline "<p>"` | headless by default; retries/timeout |
| `omp` | `omp/` | `omp -p` | LSP/DAP aware; plan-yolo cost optimization |

> More CLIs (amp, copilot, droid, kilo, mimo, command-code, cursor-agent) are
> planned — they will be re-added one at a time as each passes a live smoke test. See the
> plugin README ("Roadmap").

## Cross-CLI files

| File | Read it for |
|---|---|
| `params-mapping.md` | translating an intent (auto-approve, json, worktree, limits, ...) into each CLI's flag; scenario presets |
| `guardrails.md` | prompt building + prompt craft + 4-pillar + write-mode guardrails |
| `job-control.md` | detached jobs (`scripts/jobs.sh`) + resume/continue flags |
| `io-and-errors.md` | output parsing + report schema + error handling |
| `examples.md` | worked examples |
