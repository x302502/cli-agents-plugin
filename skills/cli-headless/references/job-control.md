# Job Control (one-shot, Bash-only)

Long delegations run **detached** through `scripts/jobs.sh` — no app-server, just a
background process plus a state directory. Use it for long reviews/refactors so the parent
does not block.

## Commands

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/jobs.sh" start [--cwd DIR] -- "<command string>"
bash "${CLAUDE_PLUGIN_ROOT}/scripts/jobs.sh" status [job-id]
bash "${CLAUDE_PLUGIN_ROOT}/scripts/jobs.sh" result <job-id>
bash "${CLAUDE_PLUGIN_ROOT}/scripts/jobs.sh" cancel <job-id>
bash "${CLAUDE_PLUGIN_ROOT}/scripts/jobs.sh" clean [--all]
```

- `start` prints a job id and returns immediately.
- State: `${CLI_AGENTS_JOB_DIR:-$HOME/.claude/cli-agents/jobs}/<job-id>/` =
  `cmd`, `cwd`, `started`, `pid`, `status` (`running|done|cancelled`), `exit`, `log`.

## Rules

- Pass the command as **one shell-quoted string** (otherwise quoting is lost).
- Foreground for tasks expected under ~60s; `start` for anything longer.
- After `start`, return the job id and tell the user to check `/cli-agents:status`.
- Read results with `jobs.sh result <id>`; stop with `jobs.sh cancel <id>`.
- Job control has **no session memory** — it only detaches the process.

## Resume / continue flags (reuse context instead of re-sending it)

Some CLIs can continue a previous run, which saves tokens on follow-ups:

| CLI | Resume / continue |
|---|---|
| `codex` | `codex exec resume <session-id> "<prompt>"` (or `--last`) |
| `agy` | `-c` / `--continue`, `--conversation <id>` |
| `pi` | `-c` / `--continue`, `-r` / `--resume` |
| `grok` | `-c` / `--continue` |
| `cline` | `--id <session-id>` |

For CLIs not listed, check `<cli> --help` for a continue/resume/session flag.