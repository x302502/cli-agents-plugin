# `claude` — models

Provider: Anthropic (no prefix; there is **no** provider argument). `--model` accepts an alias
(latest of each tier) or a full model name.

| Tier | Id / alias | Use when |
|---|---|---|
| Fast / cheapest | `haiku` | micro-tasks, formatting, listing |
| Balanced (default) | `sonnet` | most review / analysis |
| Most capable | `opus` | hardest reasoning, high-risk |
| Latest flagship alias | `fable` | newest top model |

Full names (e.g. `claude-opus-*`) are accepted too.
List: no headless listing command — see `claude --help`.
