# cli-agents plugin

Delegate heavy or long-running work from a Claude session to another AI coding-agent CLI
installed on your machine, running headless (non-interactive) and returning a clean result
to the main agent.

**Repository:** https://github.com/x302502/cli-agents-plugin

cli-agents is a **one-shot, Bash-only** delegation plugin (no app-server, no daemon).
It ships 1 agent · 2 skills · 7 commands · 1 optional hook · schemas + prompt templates.

- **`cli-delegate`** (agent) — thin orchestrator. Preloads the `cli-headless` and
  `delegation-result` skills; routes a task to any installed CLI among `claude`, `codex`,
  `agy`, `grok`, `copilot`, `pi`, `omp`, `opencode`, `mimo`, `amp`, `kilo`,
  `cline`, `command-code`, `cursor-agent`, `droid`; returns a structured report to main.
- **`cli-headless`** (skill, internal) — the invocation contract: a lean `SKILL.md` plus a
  `references/` library (per-CLI folders + params mapping, job control, guardrails, parsing).
- **`delegation-result`** (skill, internal) — presentation + safety contract: verbatim
  output, evidence boundaries, and the no-auto-fix rule.

## Plugin structure

```text
cli-agents-plugin/
├── .claude-plugin/
│   ├── plugin.json                # plugin manifest
│   └── marketplace.json           # marketplace manifest (/plugin marketplace add ...)
├── .gitignore
├── agents/
│   └── cli-delegate.md            # skills: [cli-headless, delegation-result]
├── commands/                      # /cli-agents:...
│   ├── setup.md  delegate.md  review.md
│   └── status.md  result.md  cancel.md  models.md
├── hooks/
│   └── hooks.json                 # optional Stop review gate (off by default)
├── prompts/
│   ├── review.md  adversarial-review.md  refactor.md  triage.md
├── schemas/
│   ├── delegation-report.schema.json
│   └── review-output.schema.json
├── scripts/
│   ├── jobs.sh                    # start/status/result/cancel (Bash job control)
│   ├── job-runner.sh              # internal runner for jobs.sh
│   ├── check-setup.sh             # readiness report
│   └── stop-review-gate.sh        # opt-in Stop gate
└── skills/
    ├── cli-headless/
    │   ├── SKILL.md               # lean index: decision flow, quick selection, TO helper
    │   └── references/
    │       ├── README.md          # index: binary -> folder map
    │       ├── <binary>/          # ONE FOLDER PER CLI (15)
    │       │   ├── README.md      #   description, invocation, flags, parsing
    │       │   └── models.md      #   recommended tiers + full provider / model-id list
    │       ├── params-mapping.md  # cross-CLI flag mapping + model-tier summary + presets
    │       ├── guardrails.md      # prompt building + prompt craft + 4-pillar + write-mode
    │       ├── job-control.md     # detached jobs + resume/continue flags
    │       ├── io-and-errors.md   # output parsing + report schema + error handling
    │       └── examples.md        # worked examples
    └── delegation-result/SKILL.md # verbatim output + no-auto-fix contract
```

`plugin.json` is the required manifest. Reference files are **progressive disclosure** — the
agent reads only the CLI it is about to invoke.

## Commands

| Command | What it does |
|---|---|
| `/cli-agents:setup` | Report which CLIs are installed + auth hints |
| `/cli-agents:delegate <cli> <task>` | Delegate via the `cli-delegate` subagent (`--background`, `--write`, `--model`) |
| `/cli-agents:review` | Read-only review (`--cli`, `--base`, `--adversarial`, `--background`) |
| `/cli-agents:status [job-id]` | List background jobs, or show one |
| `/cli-agents:result <job-id>` | Full log + status of a job |
| `/cli-agents:cancel <job-id>` | Kill a job's process tree |
| `/cli-agents:models <cli>` | Recommended tiers + full provider / model list |

## Background jobs (one-shot, no daemon)

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/jobs.sh" start -- "<command>"   # prints a job id
bash "${CLAUDE_PLUGIN_ROOT}/scripts/jobs.sh" status | result <id> | cancel <id>
```

State lives in `${CLI_AGENTS_JOB_DIR:-$HOME/.claude/cli-agents/jobs}/<job-id>/`.

## Review gate (optional, off by default)

A Stop hook can run a one-shot read-only review before Claude finishes:

```bash
touch ~/.claude/cli-agents/review-gate.on   # enable
rm ~/.claude/cli-agents/review-gate.on      # disable
```

> ⚠️ The gate can create a Claude↔CLI loop and drain usage limits — enable it only while you
> are actively monitoring the session.

### Architecture (Command → Agent → Skill)

Mirrors the official Claude Code pattern (same shape as the `openai-codex` plugin):

```text
cli-delegate agent  ──preloads──▶  cli-headless skill
   (own context,                    (recipes, guardrails,
    model: haiku)                    parsing, report schema)
        │
        └──Bash──▶ external CLI (headless) ──▶ result ──▶ report to main
```

The agent is **behavior/policy**; the skill is the **knowledge/reference**. A subagent does
not "call" a skill like a subroutine — it **preloads** it via the `skills:` frontmatter field,
so the contract is available inside the subagent's own context.

## What this plugin is for

Use it when you want Claude to delegate work such as:

- full-repo architecture review or security audit
- documentation generation for a large module
- git diff review or a second-opinion code review from a different model
- test case generation or test-repair loops
- autonomous multi-file refactors (with validation), isolated in a git worktree
- offloading a long task so the main Claude context stays clean

`cli-delegate` can also perform writes when you authorize them (via the target CLI's own
auto-approve + worktree isolation).

## How it works

```text
Opus (you) → Haiku wrapper (cheap) → external CLI (headless) → results back
```

The wrapper agent is lightweight Claude. The external CLI does the real work.

## Model

`cli-delegate` runs on **`model: haiku`** by default — a cheap, fast orchestrator, while the
real work runs in the external CLI. `haiku` is an alias, so it tracks the latest Haiku
automatically.

Override it if you want:
- per agent: open `/agents` and change the model for `cli-agents:cli-delegate`;
- globally: set the same model for all subagents in your Claude Code settings.

Typical flow:

1. You ask Claude to delegate a task (naming a CLI or letting it choose).
2. Claude delegates to `cli-delegate`.
3. The wrapper verifies the CLI is installed, gathers the relevant context, and builds a
   safe headless command (timeout, budget/turn caps, tool allow/deny, JSON output).
4. The external CLI runs in non-interactive mode.
5. The wrapper parses the exit code + payload and returns a `## CLI delegation report`
   plus the cleaned result to main.

## Prerequisites

`cli-delegate` uses whichever of these are installed — check with `command -v <name>`:

```bash
for c in claude codex agy grok copilot pi omp opencode mimo amp kilo cline command-code cursor-agent droid; do
  printf '%-14s' "$c"; command -v "$c" >/dev/null 2>&1 && echo OK || echo MISSING
done
```

> **Note (macOS):** this machine has no `timeout`/`gtimeout` (coreutils not installed).
> `cli-delegate` uses a portable perl-based timeout helper instead; no extra install needed.

## Install

**From GitHub (recommended):**

```text
/plugin marketplace add x302502/cli-agents-plugin
/plugin install cli-agents@cli-agents
/reload-plugins
/cli-agents:setup
```

The repository ships `.claude-plugin/marketplace.json`, so `/plugin marketplace add` can
point straight at it.

**Local dev (no install):**

```bash
claude --plugin-dir ./cli-agents-plugin
```

**Clone + install from a path:**

```bash
git clone https://github.com/x302502/cli-agents-plugin
# then, in Claude Code:
/plugin install ./cli-agents-plugin
```

No npm install — the plugin is Bash + Markdown only. You just need at least one of the
target CLIs installed (see Prerequisites).

## Usage

In your Claude Code session (Opus):

```text
> Use cli-delegate to run codex on src/payments and report race conditions
> Use cli-delegate to have droid refactor the auth module and run the tests
> Use cli-delegate to ask cursor-agent for a second opinion on the last commit
```

Or just describe the task — Claude auto-delegates when it matches an agent description.

### Choosing a CLI

The user's explicit choice always wins. Otherwise `cli-delegate` picks by task shape:

| Task | Suggested CLI |
| --- | --- |
| Strongest reasoning / cross-file correctness | `claude`, `droid`, `codex` |
| Fast, cheap, read-only review / docs / micro-fix | `pi`, `amp`, `cline` |
| Autonomous repo work + multi-agent validation | `droid exec --mission`, `omp --plan-yolo` |
| Huge-context scan (1M+) | `agy` |
| Sandboxed file work | `codex -s workspace-write`, `cursor-agent --sandbox enabled` |
| Isolated git worktree | `command-code -w`, `cursor-agent -w`, `grok -w`, `droid -w` |
| Second opinion from another vendor | any CLI from a different family than the host |

## Example prompts

### Delegate to a specific CLI

```text
Use cli-delegate to run codex exec on this repo in read-only mode.
Review src/payments for race conditions and return a table: file, risk, severity, fix.
```

```text
Use cli-delegate to have droid execute: refactor the auth module from callbacks to
async/await, run npm test, fix failures. Autonomy medium, JSON output.
```

```text
Use cli-delegate to ask cursor-agent for a second opinion on the changes in the last commit.
Read-only (--plan), JSON output.
```

### Delegate a long autonomous task (writes)

```text
Use cli-delegate to run command-code in an isolated worktree to fix the failing
test suite in src/. Auto-accept, no-session, max-turns 20.
```

### Let the agent choose the CLI

```text
Use cli-delegate to audit this repository for security issues. Pick the best available
CLI, default to read-only, and return findings grouped by severity.
```

## How to write good requests

The agent works best when the request is explicit about scope and output:

1. The target scope: repo, folder, file, or git diff.
2. The task: audit, review, refactor, fix, document, summarize, or generate tests.
3. The focus: security, performance, architecture, correctness, or dependencies.
4. The desired output: bullets, checklist, table, or prioritized findings.
5. Optional: which CLI to use, whether edits are allowed, budget, and timeout.

Example:

```text
Use cli-delegate to run codex in read-only mode over src/payments and src/orders.
Return a markdown table with file, risk, severity, and suggested fix.
```

## Delegation safety model (4 pillars)

`cli-delegate` applies four guardrails on every call. They mirror the
`cli-headless-book` 4-pillar architecture:

1. **One-Shot Execution** — always non-interactive (`-p`, `exec`, `run`, `-x`, bare `cline`);
   never a TUI.
2. **Security Perimeter** — allow at the flag level, deny dangerous patterns explicitly
   (`rm *`, `sudo *`, `docker *`, `git push --force*`, `cat *.env*`).
3. **Economics & Limits** — always a timeout; budget cap (`--max-budget-usd`) and turn cap
   (`--max-turns`) where supported.
4. **Structured I/O** — prefer JSON / stream-json output and check exit code **and** payload.

For write tasks the agent defaults to read-only unless authorized, prefers an isolated git
worktree, and never pushes to `main`.

## Headless CLI quick reference

| Binary | Headless invocation | Auto-approve | Structured output |
| --- | --- | --- | --- |
| `claude` | `claude -p` | `--permission-mode dontAsk` | `--output-format json` / `--json-schema` |
| `codex` | `codex exec` | `--dangerously-bypass-approvals-and-sandbox` | `--json` / `--output-schema` |
| `agy` | `agy -p` | `--dangerously-skip-permissions` | `--output-format json` / `--json-schema` |
| `grok` | `grok -p` | `--permission-mode dontAsk` | `--output-format json` / `--json-schema` |
| `copilot` | `copilot -p` | `--allow-all-tools` / `--yolo` | `--output-format json` |
| `pi` | `pi -p` | auto in `-p` | `--mode json` |
| `omp` | `omp -p` | `--plan-yolo` | `--mode json` |
| `opencode` | `opencode run` | `--auto` | `--format json` |
| `mimo` | `mimo run` | `--never-ask --trust` | `--format json` |
| `amp` | `amp -x` | `--dangerously-skip-permissions` | `--stream-json` |
| `kilo` | `kilo run` | `--auto` | `--format json` |
| `cline` | `cline "<prompt>"` | on by default | `--json` |
| `command-code` | `command-code -p` | `--auto-accept` | `--output-format json` |
| `cursor-agent` | `cursor-agent -p` | `--force` / `--yolo` | `--output-format json` |
| `droid` | `droid exec` | `--auto low\|medium\|high` | `--output-format json` |

## Limits

- Depends on the target CLI(s) being installed and authenticated.
- Large prompts can still time out, so scope the input when possible.
- Results are advisory. Final engineering judgment remains with Claude or the user.

## Troubleshooting

If the plugin does not work as expected:

1. Check the CLI is installed: `command -v <name>` (e.g. `command -v codex`).
2. Run the CLI once manually to complete authentication (e.g. `codex`, `droid`).
3. Confirm the plugin path points to the folder containing `.claude-plugin/plugin.json`.
4. Retry with a narrower request if the run times out.
5. If a delegated CLI reports a permission prompt, add its auto-approve flag (see the table).

