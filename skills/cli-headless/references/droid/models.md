# `droid` — models

Provider: Factory (multi-vendor; **no** separate provider argument — the vendor is in the id
or the `custom:` prefix). `-m/--model <id>` (default `claude-opus-4-8`).

| Role | Model id |
|---|---|
| Default | `claude-opus-4-8` |
| Mission worker | fast model (e.g. `claude-sonnet-*`) |
| Mission validator | a *different vendor* (e.g. `gpt-5`) |
| Custom BYO | `custom:<provider>-<model>` (e.g. `custom:deepseek-v3`, `custom:qwen-turbo`) |

Mission roles: `--worker-model`, `--validator-model`.
List: `droid exec --model <id> --list-tools`; the model set is account-dependent.
