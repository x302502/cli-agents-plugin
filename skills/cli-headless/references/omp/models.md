# `omp` — models

`omp` accepts a **provider argument** (`--provider`) and/or a fuzzy model name. Role flags:
`--model`, `--smol`, `--slow`, `--plan`.

| Provider | Model / pattern | Role |
|---|---|---|
| any (fuzzy) | `opus` | `--slow` (strongest) |
| any (fuzzy) | `sonnet` | `--model` (default) |
| any (fuzzy) | `haiku` | `--smol` (fast/cheap) |
| `openai` | `gpt-5.2` / `openai/gpt-5.2` | default / alt |
| any | `claude-haiku` | `--plan-yolo-into` executor |

- `--plan-yolo-into <model>` sets the cheaper executor.
- Env overrides: `PI_SMOL_MODEL`, `PI_SLOW_MODEL`, `PI_PLAN_MODEL`.
- List: fuzzy names — see `omp --help`.
