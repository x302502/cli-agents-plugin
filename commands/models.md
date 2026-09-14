---
description: Show recommended model tiers and the full provider/model list for a CLI
argument-hint: "<cli>  (e.g. codex, cline, kilo)"
allowed-tools: Bash, Read, Glob
---

Show the model reference for the CLI in `$ARGUMENTS`.

- If `$ARGUMENTS` is empty: list the CLI folders under
  `skills/cli-headless/references/` and ask which one to show.
- Otherwise read and present:

```bash
cat "${CLAUDE_PLUGIN_ROOT}/skills/cli-headless/references/$ARGUMENTS/models.md"
```

Highlight the fast / default / strongest picks. If the file is missing, say the CLI is
unknown and list the valid ones.