# `omp` — Oh My Pi (Can Bölük / Stencil)

Rust-native core with LSP/DAP. Headless: `omp -p`.
Best for: large codebases needing type/LSP awareness, and plan→execute cost optimization.

## Invocation

```bash
TO 180 omp -p "<PROMPT>" \
  --plan-yolo --plan-yolo-into "claude-haiku" \
  --no-session --no-lsp --no-pty --mode json 2>/dev/null
```

## Key flags

| Flag | Purpose |
|---|---|
| `-p, --print` | non-interactive |
| `--plan-yolo` | read-only plan, auto-approve, then execute |
| `--plan-yolo-into <model>` | cheaper executor model for the plan |
| `--mode text\|json\|rpc` | output mode |
| `--no-session` | ephemeral |
| `--no-lsp` | skip language servers (fast CI startup) |
| `--no-pty` (or `PI_NO_PTY=1`) | avoid PTY/buffer issues on CI |
| `--model` / `--smol` / `--slow` / `--plan` | role models |
| `omp acp` | ACP server over stdio |

## Output / parsing

- `--mode json` emits a JSON event stream; take the trailing result/assistant text.

## Notes

- `--plan-yolo` + `--plan-yolo-into <cheap-model>` is the headline cost-saver.
- `omp cleanse --no-session` auto-fixes diagnostics with parallel subagents.


## Recommended models

Recommended tiers and the full model-id / provider list: see [models.md](models.md).
