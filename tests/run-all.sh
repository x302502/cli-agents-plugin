#!/usr/bin/env bash
# cli-agents test runner. Unit suites always run (offline); live smoke with SMOKE=1.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

echo '== 1. Manifests / static (TC-M*) =='
bash unit/test-manifests.sh || exit 1
echo
echo '== 2. run-failure classifier (TC-C*) =='
bash unit/test-check-run.sh || exit 1
echo
echo '== 3. job control (TC-J*) =='
bash unit/test-jobs.sh || exit 1
echo
echo '== 4. TO timeout helper (TC-T*) =='
bash unit/test-to-helper.sh || exit 1

if [ "${SMOKE:-0}" = "1" ]; then
  echo
  echo '== 5. live per-CLI smoke (TC-S*) =='
  bash smoke/test-clis.sh || exit 1
else
  echo
  echo '(step 5 skipped — live smoke is opt-in)'
  echo '  run:  SMOKE=1 bash tests/run-all.sh'
  echo '  or:   SMOKE=1 SMOKE_CLIS=codex,pi bash tests/smoke/test-clis.sh'
fi

echo
echo 'ALL SUITES PASSED'