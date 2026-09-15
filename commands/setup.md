---
description: Check which external CLI agents are installed and how to authenticate them
allowed-tools: Bash, Read
---

Report CLI readiness. Run:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/scripts/check-setup.sh"
```

Present the output as a table. For any installed CLI the user likely has not authenticated,
mention the usual login step (e.g. `codex login`, run `agy` once interactively). Do not install
or authenticate on the user's behalf unless they ask.