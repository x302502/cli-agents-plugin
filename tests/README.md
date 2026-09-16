# Test Plan & Suite

Unit suites run without network or CLIs. The live CLI smoke suite is opt-in (`SMOKE=1`).

```bash
bash tests/run-all.sh                 # unit suites only (fast, offline)
SMOKE=1 bash tests/run-all.sh         # + live per-CLI smoke (needs installed+authed CLIs)
SMOKE=1 SMOKE_CLIS=codex,pi bash tests/smoke/test-clis.sh   # subset
```

## Test-case matrix

| ID | Suite | What it verifies | How | Cost |
|---|---|---|---|---|
| **Manifests** | | | | |
| TC-M1 | unit/test-manifests.sh | All 5 JSON files are syntactically valid | `jq empty` | offline |
| TC-M2 | unit/test-manifests.sh | `plugin.json` and `marketplace.json` versions match | `jq` compare | offline |
| TC-M3 | unit/test-manifests.sh | Manifest schema: `name`, `author` object, agents/skills present | `jq -e` | offline |
| TC-M4 | unit/test-manifests.sh | Every agent/skill/command has valid frontmatter (`name`, `description`) | `yaml.safe_load` | offline |
| TC-M5 | unit/test-manifests.sh | Every `.md` has balanced code fences | `re.findall`, even count | offline |
| TC-M6 | unit/test-manifests.sh | Supported-CLI list is consistent (check-setup.sh ↔ agent loop ↔ delegate regex ↕ README) | grep compare | offline |
| TC-M7 | unit/test-manifests.sh | Every supported CLI folder ships `README.md` + `models.md`; no phantom folders | file existence | offline |
| TC-M8 | unit/test-manifests.sh | All 5 `scripts/*.sh` pass `bash -n` | `bash -n` | offline |
| TC-M9 | unit/test-manifests.sh | `delegation-report.schema.json` requires all 11 report fields | `jq '.required\|length == 11'` | offline |
| TC-M10 | unit/test-manifests.sh | README carries the git-history restore instructions (Roadmap) | grep `git revert` | offline |
| **Classifier** | | | | |
| TC-C1..C10 | unit/test-check-run.sh | `check-run.sh` classifies 10 outcomes correctly: OK, TIMEOUT, CLI_MISSING, AUTH, RATE_LIMIT, BAD_FLAGS, CONTEXT_OVERFLOW, PERMISSION, NONZERO_EXIT, EMPTY_OUTPUT | fixture logs → assert TYPE | offline |
| **Job control** | | | | |
| TC-J1 | unit/test-jobs.sh | `start` emits a `ja_<ts>_<rand>` id, writes `running` status | run + read state files | offline |
| TC-J2 | unit/test-jobs.sh | Finished job: `exit` recorded, `status=done`, `result` includes full log | `echo hello-job` | offline |
| TC-J3 | unit/test-jobs.sh | Caller PATH is snapshotted and restored in the job (node-version fix) | job echoes `$PATH`, diff vs caller | offline |
| TC-J4 | unit/test-jobs.sh | `cancel` kills the **whole process tree** (nested children, no orphans) | `sleep 300 & sleep 300 & wait` → pgrep empty | offline |
| TC-J5 | unit/test-jobs.sh | Multi-argument `start` prints a quoting-contract WARNING to stderr | capture stderr | offline |
| TC-J6 | unit/test-jobs.sh | `clean` removes finished jobs, keeps running ones | state-dir listing | offline |
| **TO timeout helper** | | | | |
| TC-T1 | unit/test-to-helper.sh | The `TO` helper documented in SKILL.md runs a normal command and propagates exit 0 | extract from SKILL.md → run | offline |
| TC-T2 | unit/test-to-helper.sh | `TO` times out with **124** (not 255 = perl syntax error) | `TO 1 sleep 5` | offline |
| TC-T3 | unit/test-to-helper.sh | Child exit code is propagated (`exit 7` → 7) | `bash -c 'exit 7'` | offline |
| TC-T4 | unit/test-to-helper.sh | Multi-word / quoted arguments survive the helper | `echo "two words"` | offline |
| TC-T5 | unit/test-to-helper.sh | The documented **one-line** form also works (agents inline it) | grep one-liner → run | offline |
| TC-T6 | unit/test-to-helper.sh | No `TO` definition in the repo is missing the `;` after `sub{}` | grep `exit 124}$` → 0 hits | offline |
| TC-T7 | unit/test-to-helper.sh | The one-line form also times out with 124 | `TO 1 sleep 5` | offline |
| **Live smoke (opt-in)** | | | | |
| TC-S1..S7 | smoke/test-clis.sh | Each of the 7 supported CLIs runs its canonical one-shot recipe, exits 0, and its output contains `OK` | live run per CLI (60s cap) | tokens |
| TC-S8 | smoke/test-clis.sh | `SMOKE_CLIS=<subset>` runs only the named CLIs | env filter | tokens |

## Lane-severity mapping

| Severity | Tests that catch it first |
|---|---|
| Crash / High | TC-S* (live), TC-M8 (syntax) |
| Wrong flags / recipes | TC-S* per CLI |
| Process/state bugs (orphans, PATH, quoting) | TC-J3, TC-J4, TC-J5 |
| Classifier regressions | TC-C1..C10 |
| Timeout helper broken (every call exits 255) | TC-T1..T7 |
| Docs drift (lists, versions, schema, frontmatter) | TC-M1..M10 |
