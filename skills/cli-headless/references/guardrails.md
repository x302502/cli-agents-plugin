# Guardrails & Prompt Building

## Building The Delegated Prompt

One clear task per call. If the parent asks for several things, make several calls (or one
call per CLI). Always include output instructions so the CLI returns something parseable:

1. **Scope:** exactly which paths, files, diff, or branch to look at.
2. **Task:** audit / review / refactor / fix / document / list / summarize.
3. **Focus:** security / performance / architecture / correctness / dependencies.
4. **Constraints:** read-only vs write, which tests to run, what to avoid.
5. **Output contract:** e.g. *"Return a markdown table with columns file, line, issue,
   severity, fix"* or *"Return JSON matching the provided schema; add no prose."*

Scope the input. Prefer file references over dumping the whole repo:
- Single file: `claude -p "review @./src/x.ts"`, `pi -p @tsconfig.json "check strict flags"`.
- Many files: `find src -name '*.ts' | grep -v node_modules | head -80 | xargs cat | <cli>`.
- Long logs/stack traces: pipe via stdin (`codex exec -`, `amp < prompt.txt`).

For write tasks, tell the CLI to run the project's tests/verification after editing, and to
report the exact files it changed.

---

## 4-Pillar Guardrails (always apply)

1. **One-Shot Execution:** always use the CLI's non-interactive flag (`-p`, `exec`, `run`,
   `-x`, or bare `cline`). Never launch a TUI. Redirect `stderr` to `/dev/null`.
2. **Security Perimeter:** allow broadly at the flag level, deny dangerous patterns
   explicitly. Always deny `rm *`, `sudo *`, `docker *`, `git push --force*`, `cat *.env*`,
   `mcp__*` (as supported). Auto-approve only what the task needs.
3. **Economics & Limits:** always set a timeout (`TO <secs>`) and, where supported,
   `--max-budget-usd` (claude), `--max-turns` (claude, grok, command-code), `--timeout`
   (cline). Keep default budget <= $1.50 and turns <= 20.
4. **Structured I/O:** prefer `json` / `stream-json` / `--output-format json` / `--json`
   over free text, and always check **both** the exit code and the parsed payload.

### Write-Mode Guardrails

- **Default to read-only.** Only enable edits when the parent/user explicitly authorizes them.
- Prefer running write tasks in an **isolated git worktree** via the CLI's own flag
  (`droid -w`, `cursor-agent -w`, `command-code -w`, `grok -w`) when available.
- Never allow a delegated CLI to push to `main` or force-push.
- Record the working tree before/after so you can report what changed:

```bash
git status --porcelain > /tmp/delegate-before.txt
# ... run the CLI ...
git status --porcelain > /tmp/delegate-after.txt
diff /tmp/delegate-before.txt /tmp/delegate-after.txt || true
```

---

## Prompt craft (model-agnostic)

Applies to every CLI. Do not raise reasoning/model tier before trying these.

- One clear task per run; split unrelated asks into separate runs.
- Say what "done" looks like — do not assume the CLI infers the end state.
- Pin the output contract (shape, ordering, brevity) instead of trusting free text.
- Add grounding + verification rules where unsupported guesses would hurt (review, research, risky fixes).
- Prefer a tighter prompt contract over raising reasoning; escalate the model tier only after that.
- Keep claims anchored to evidence; mark hypotheses as hypotheses.
