# `cursor-agent` — models

Provider: Cursor (**no** provider argument). `--model <id>`.

| Role | Model id |
|---|---|
| Fast | a `-mini` / `-fast` variant |
| Default | `gpt-5` or `sonnet-4` |
| Strongest / thinking | `sonnet-4-thinking` |

Parameterized models accept quoted brackets, e.g. `--model 'gpt-5[...]'`.
List: `cursor-agent models` (authenticate: `agent login` / `CURSOR_API_KEY`).
