# `omp` — models

`omp` takes a **provider argument** (`--provider`, legacy) and a **fuzzy model name**
(`--model`): `"opus"`, `"gpt-5.2"`, or `"openai/gpt-5.2"` all resolve. Role flags let you pin
a different model per job class:

| Role flag | Env override | Use for |
|---|---|---|
| `--model <fuzzy>` | — | the main model |
| `--smol <fuzzy>` | `PI_SMOL_MODEL` | fast/cheap work; also the default target of `--plan-yolo-into` / `--prewalk-into` |
| `--slow <fuzzy>` | `PI_SLOW_MODEL` | thorough reasoning / security review |
| `--plan <fuzzy>` | `PI_PLAN_MODEL` | architectural planning |

Regenerate the full inventory with: **`omp models`** (lists provider, context window, max-out,
supported `--thinking` levels, and image support). On this machine: **234 models / 3 providers**.

## Recommended tiers

| Tier | Pick | Why |
|---|---|---|
| Fast / cheap (`--smol`) | `claude-haiku-4.5` | cheap executor for `--plan-yolo-into` / `--prewalk-into` |
| Default (`--model`) | `claude-sonnet-5` | best price/quality for coding |
| Strongest (`--slow`) | `claude-opus-5` | 1M context, `--thinking max`; security + cross-file reasoning |
| OpenAI alt | `gpt-5.6-sol` / `gpt-5.6-terra` / `gpt-5.6-luna` | newest GPT tier |
| Codex-specialised | `gpt-5.3-codex` / `gpt-5.2-codex` | code-heavy edits |
| Free-tier-ish | `gemini-3.8-flash`, `grok-code-fast-1`, `raptor-mini` | high volume, low cost |

## Provider inventory (`omp models`, v18.2.1)

| Provider | Models | Notes |
|---|---|---|
| `amazon-bedrock` | **182** | AWS Bedrock; ids are `anthropic.*`, `amazon.nova-*`, plus regional prefixes (`eu.`, `us.`, `apac.`, `au.`, `ca.`, `global.`) |
| `github-copilot` | **47** | the provider authenticated on this machine |
| `bedrock-mantle` | **5** | `openai.gpt-5.4`, `openai.gpt-5.5`, `openai.gpt-5.6-luna`, `openai.gpt-5.6-sol`, `openai.gpt-5.6-terra` |

### `github-copilot` (47)

| Provider | Model id | Family |
|---|---|---|
| `github-copilot` | `claude-opus-5`, `claude-opus-4.8`, `claude-opus-4.7`, `claude-opus-4.6`, `claude-opus-4.5` | Anthropic opus |
| `github-copilot` | `claude-sonnet-5`, `claude-sonnet-4.6`, `claude-sonnet-4.5`, `claude-sonnet-4` | Anthropic sonnet |
| `github-copilot` | `claude-haiku-4.5` | Anthropic haiku (cheap executor) |
| `github-copilot` | `claude-fable-5.1`, `claude-fable-5` | Anthropic fable |
| `github-copilot` | `gpt-6-astra` | newest OpenAI |
| `github-copilot` | `gpt-5.6-sol`, `gpt-5.6-terra`, `gpt-5.6-luna` | GPT-5.6 tier |
| `github-copilot` | `gpt-5.5`, `gpt-5.4`, `gpt-5.4-mini`, `gpt-5.4-nano` | GPT-5.4/5.5 |
| `github-copilot` | `gpt-5.3-codex`, `gpt-5.2-codex`, `gpt-5.2`, `gpt-5.1-codex-max`, `gpt-5.1-codex`, `gpt-5.1-codex-mini`, `gpt-5.1`, `gpt-5`, `gpt-5-mini` | GPT-5.x + codex variants |
| `github-copilot` | `gpt-4.1`, `gpt-4o` | legacy OpenAI |
| `github-copilot` | `gemini-3.8-flash`, `gemini-3.7-flash`, `gemini-3.6-flash`, `gemini-3.5-flash`, `gemini-3-flash-preview` | Gemini flash |
| `github-copilot` | `gemini-3.1-pro-preview`, `gemini-3-pro-preview`, `gemini-2.5-pro` | Gemini pro |
| `github-copilot` | `grok-4.6`, `grok-4.5`, `grok-code-fast-1` | xAI |
| `github-copilot` | `kimi-k3`, `kimi-k2.7-code` | Moonshot |
| `github-copilot` | `mai-code-1.1-flash`, `mai-code-1-flash-picker`, `raptor-mini` | Microsoft MAI / cheap |

### `amazon-bedrock` (182) — highlights

| Provider | Model id | Context | Max-out | `--thinking` |
|---|---|---|---|---|
| `amazon-bedrock` | `anthropic.claude-opus-5` | 1M | 128K | `low,medium,high,max` |
| `amazon-bedrock` | `anthropic.claude-sonnet-5` | 1M | 128K | `low,medium,high,max` |
| `amazon-bedrock` | `anthropic.claude-opus-4-8` / `4-7` / `4-6-v1` | 1M | 128K | `low,medium,high,max` |
| `amazon-bedrock` | `anthropic.claude-3-5-haiku-20241022-v1:0` | 200K | 8.2K | — |
| `amazon-bedrock` | `amazon.nova-pro-v1:0` / `nova-lite-v1:0` / `nova-micro-v1:0` | 300K / 300K / 128K | 10K | — |

Regional duplicates exist for most ids (`eu.`, `us.`, `apac.`, `au.`, `ca.`, `global.` prefixes) —
pick the region closest to your data residency; they are the same model.

## Notes

- Fuzzy matching means `--model sonnet` works without a provider prefix; add the prefix
  (`github-copilot/claude-sonnet-5`) only when the same fuzzy name is ambiguous across providers.
- `--thinking` levels are **per model** — `omp models` shows which each one supports
  (e.g. `claude-opus-5` → `low,medium,high,max`; Bedrock haiku-4.5 → `minimal,low,medium,high`).
- `omp usage` shows remaining provider limits for every authenticated account;
  `omp bench` measures TTFT/prefill vs decode throughput if you want to pick empirically.
- `omp token` prints the API key/OAuth token for a provider (handle with care — never log it).
