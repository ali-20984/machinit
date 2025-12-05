#!/usr/bin/env bash
# Verify that the checker --check-only mode writes report and exits (warning-only by default)
set -euo pipefail

REPO_ROOT="$(dirname "$0")/.."
CHECK_SCRIPT="$REPO_ROOT/scripts/011_check_aliases_functions_conflicts.sh"
REPORT="$REPO_ROOT/docs/ALIASES_FUNCTIONS_CONFLICTS_REPORT.md"

echo "Running check-only test..."

if [ ! -x "$CHECK_SCRIPT" ]; then
    echo "FAIL: check script not executable: $CHECK_SCRIPT"
    exit 1
fi

# Run in check-only mode (should exit 0 in warning-only default)
if bash "$CHECK_SCRIPT" --check-only "$REPO_ROOT/assets"; then
    echo "PASS: check-only completed (warning-only)"
else
    echo "FAIL: check-only should not abort when conflicts exist (warning-only default)"
    exit 1
fi

# Ensure report exists
if [ -f "$REPORT" ]; then
    echo "PASS: Report generated"
    exit 0
else
    echo "FAIL: Report not generated: $REPORT"
    exit 1
fi
