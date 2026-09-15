# Examples

## Worked Examples

**A. Read-only second opinion from another model (safe default):**
```bash
TO 120 codex exec "Review src/payments/** for race conditions and missing transaction boundaries. Return a markdown table: file, risk, severity, fix." --sandbox read-only --ephemeral --skip-git-repo-check --json -o /tmp/codex-review.txt 2>/dev/null
```

**B. Autonomous multi-file refactor with validation (writes):**
```bash
TO 240 grok -p "Refactor the auth module from callbacks to async/await, then run 'npm test' and fix failures. Report files changed." --permission-mode dontAsk --output-format json 2>/dev/null
```

**C. Huge-context documentation sweep (cheap, read-only):**
```bash
TO 180 agy -p "Generate module docs for every file under src/services. Return markdown with a section per module." --mode plan --output-format json --print-timeout 3m 2>/dev/null
```

**D. Fast micro-fix with a small model:**
```bash
TO 90 pi -p "Add a missing PORT validation in src/config.ts and update README." --mode json --no-session --tools read,edit,write 2>/dev/null
```

**E. Full-repo security audit (read-only, structured):**
```bash
TO 200 codex exec "Audit this repo for injection, secrets, and missing authz. Return JSON: {findings:[{file,line,severity,issue,fix}]}." --sandbox read-only --ephemeral --skip-git-repo-check --json -o /tmp/audit.txt 2>/dev/null
```

**F. Autonomous test-writing pass (write):**
```bash
TO 240 cline "Add integration tests covering the order flow and make them pass. Run 'npm test' when done and report results." --json --timeout 240 2>/dev/null
```


