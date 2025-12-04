#!/usr/bin/env bash
# Verify that the checker exits non-zero when --abort-on-conflict is supplied and conflicts exist
set -euo pipefail

REPO_ROOT="$(dirname "$0")/.."
CHECK_SCRIPT="$REPO_ROOT/scripts/011_check_aliases_functions_conflicts.sh"

echo "Running abort-on-conflict test..."

if [ ! -x "$CHECK_SCRIPT" ]; then
  echo "FAIL: check script not executable: $CHECK_SCRIPT"
  exit 1
fi

# Run the checker in abort mode — the repository has known conflicts so we expect non-zero
if bash "$CHECK_SCRIPT" --abort-on-conflict "$REPO_ROOT/assets"; then
  echo "FAIL: Expected non-zero exit in abort-on-conflict mode, but got zero"
  exit 1
else
  echo "PASS: Checker returned non-zero as expected in abort-on-conflict mode"
fi

# Ensure report exists
REPORT="$REPO_ROOT/docs/ALIASES_FUNCTIONS_CONFLICTS_REPORT.md"
if [ -f "$REPORT" ]; then
  echo "PASS: Report generated"
  exit 0
else
  echo "FAIL: Report not generated: $REPORT"
  exit 1
fi
