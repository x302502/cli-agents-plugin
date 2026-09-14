# `pi` — models

`--model <provider>/<model>` **or** `--provider <name> --model <model>` (pi has a provider
argument). Optional `:thinking` suffix. Regenerate with `pi --list-models`.

| Provider | Model | Context | Max out |
|---|---|---|---|
| github-copilot | claude-haiku-4.5 | 200K | 64K |
| github-copilot | claude-opus-4.7 | 1M | 32K |
| github-copilot | claude-opus-4.8 | 1M | 64K |
| github-copilot | claude-opus-5 | 1M | 64K |
| github-copilot | claude-sonnet-5 | 1M | 128K |
| github-copilot | gemini-3.5-flash | 200K | 64K |
| github-copilot | gemini-3.6-flash | 1M | 64K |
| github-copilot | gemini-3.7-flash | 1M | 64K |
| github-copilot | gemini-3.8-flash | 1M | 64K |
| github-copilot | gpt-5-mini | 264K | 64K |
| github-copilot | gpt-5.3-codex | 1M | 128K |
| github-copilot | gpt-5.4 | 1M | 128K |
| github-copilot | gpt-5.4-mini | 400K | 128K |
| github-copilot | gpt-5.5 | 1M | 128K |
| github-copilot | gpt-5.6-luna | 1.1M | 128K |
| github-copilot | gpt-5.6-sol | 1.1M | 128K |
| github-copilot | gpt-5.6-terra | 1.1M | 128K |
| github-copilot | gpt-6-astra | 1.1M | 128K |
| github-copilot | grok-4.5 | 500K | 128K |
| github-copilot | grok-4.6 | 500K | 128K |
| github-copilot | mai-code-1-flash-picker | 256K | 128K |
| github-copilot | mai-code-1.1-flash | 256K | 128K |
| openai-codex | gpt-5.3-codex-spark | 128K | 128K |
| openai-codex | gpt-5.4 | 272K | 128K |
| openai-codex | gpt-5.4-mini | 272K | 128K |
| openai-codex | gpt-5.5 | 272K | 128K |
| openai-codex | gpt-5.6-luna | 272K | 128K |
| openai-codex | gpt-5.6-sol | 272K | 128K |
| openai-codex | gpt-5.6-terra | 272K | 128K |
| openai-codex | gpt-6-astra | 272K | 128K |

## Picks

| Role | Model |
|---|---|
| Fast/cheap | `github-copilot/claude-haiku-4.5` or `github-copilot/gpt-5.4-mini` |
| Default | `github-copilot/claude-sonnet-5` |
| Strongest | `github-copilot/claude-opus-5` |
| Huge context | `github-copilot/gemini-3.8-flash` (1M) |
