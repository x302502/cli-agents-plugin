# `cline` — models

`cline` uses a **provider argument** (`-P, --provider <id>`) plus `-m, --model <model-id>`.
Default provider: `cline` (bound to the Cline subscription / ClinePass).

## Providers

| Provider id | Notes |
|---|---|
| `cline` | default (recommended / free catalog) |
| `cline-pass` | ClinePass subscription (maps to storage provider `cline`) |
| `anthropic`, `openai`, `openrouter`, `gemini`, `vertex`, `xai`, `mistral`, `groq`, `deepseek`, `cerebras` | BYO API-key providers |
| `bedrock`, `sapaicore` | AWS Bedrock / SAP AI Core |

Usage: `cline -P <provider> -m <model-id> "..."`.

## Newest example models (on this machine)

| Provider | Model id | Tag |
|---|---|---|
| `cline` | `anthropic/claude-opus-4.6` | BEST |
| `cline` | `anthropic/claude-sonnet-4.6` | NEW |
| `cline` | `google/gemini-3.1-pro-preview` | NEW |
| `cline` | `openai/gpt-5.3-codex` | NEW |
| `cline` | `kwaipilot/kat-coder-pro` | FREE |
| `cline` | `arcee-ai/trinity-large-preview:free` | FREE |

## ClinePass (`cline-pass`)

Last used here: `cline-pass/glm-5.2`. Other ClinePass ids seen: `cline-pass/deepseek-v4.1-flash`,
`z-ai/glm-5.3-flash`. Use `-P cline-pass -m <id>`.

## Config / listing

- `cline auth <provider>` — authenticate a provider and set the model for it.
- `cline config` — show current configuration (needs a TTY).
- State lives in `~/.cline/data/settings/providers.json`.
- No `cline models` command; the model picker is in the TUI.
