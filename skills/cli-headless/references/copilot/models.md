# `copilot` — models

Provider: GitHub Copilot (**no** provider argument). `--model <id>` or `--model auto`.

GitHub Copilot's model set (the `github-copilot` catalog exposed by `pi`):

| Model id | Notes |
|---|---|
| `claude-opus-5`, `claude-opus-4.8`, `claude-opus-4.7` | strongest |
| `claude-sonnet-5` | balanced (recommended) |
| `claude-haiku-4.5` | fastest |
| `gpt-6-astra`, `gpt-5.6-sol` / `terra` / `luna`, `gpt-5.5` | OpenAI frontier |
| `gpt-5.4`, `gpt-5.4-mini`, `gpt-5-mini` | OpenAI mid/small |
| `gpt-5.3-codex` | code-tuned |
| `gemini-3.8-flash`, `gemini-3.7-flash`, `gemini-3.6-flash`, `gemini-3.5-flash` | Google |
| `grok-4.6`, `grok-4.5` | xAI |
| `mai-code-1.1-flash` | Microsoft MAI |
| `auto` | Copilot picks per task |

List: the exact set depends on your plan (verified via the `github-copilot` catalog).
`copilot models` is not a valid headless command.
