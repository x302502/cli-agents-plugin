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
| `copilot` | `copilot/` | `copilot -p` | GitHub-centric flows; usage telemetry |
| `pi` | `pi/` | `pi -p` | fastest startup; micro-tasks; RPC |
| `omp` | `omp/` | `omp -p` | Rust core; LSP; plan→execute |
| `opencode` | `opencode/` | `opencode run` | client/server; ACP |
| `kilo` | `kilo/` | `kilo run` | cloud/local worker; server |
| `mimo` | `mimo/` | `mimo run` | Xiaomi token plan; server; PR |
| `amp` | `amp/` | `amp -x` | Claude-Code-compatible stream-json |
| `cline` | `cline/` | `cline "<p>"` | headless by default; retries/timeout |
| `command-code` | `command-code/` | `command-code -p` | taste learning; worktree; `exit 8` cap |
| `cursor-agent` | `cursor-agent/` | `cursor-agent -p` | Cursor models; sandbox; worktree |
| `droid` | `droid/` | `droid exec` | multi-agent mission; autonomy tiers |

## Cross-CLI files

| File | Read it for |
|---|---|
| `params-mapping.md` | translating an intent (auto-approve, json, worktree, limits, ...) into each CLI's flag; scenario presets |
| `guardrails.md` | prompt building + prompt craft + 4-pillar + write-mode guardrails |
| `job-control.md` | detached jobs (`scripts/jobs.sh`) + resume/continue flags |
| `io-and-errors.md` | output parsing + report schema + error handling |
| `examples.md` | worked examples |
