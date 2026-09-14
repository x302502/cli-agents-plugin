# `codex` — models

Provider: OpenAI (no prefix; **no** provider argument). `-m, --model <id>`.

| Tier | Model id | Use when |
|---|---|---|
| Fast / cheap | `gpt-5.4-mini` | everyday tasks (272K ctx) |
| Code-tuned fast | `gpt-5.3-codex-spark` | quick code edits (128K ctx) |
| Default | `gpt-5.4` | frontier general/code work |
| Stronger | `gpt-5.5` / `gpt-5.6-sol` / `gpt-5.6-terra` | complex work |
| Most capable | `gpt-6-astra` | demanding reasoning & agents |
| Documented example | `o3` | — |

List: `codex --help`; enumerable via `pi --list-models` → provider `openai-codex`;
`-c model=<id>` overrides.
