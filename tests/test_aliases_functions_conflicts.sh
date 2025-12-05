#!/usr/bin/env bash
# Verify that the alias/function conflicts checker runs and produces a report
set -euo pipefail

REPO_ROOT="$(dirname "$0")/.."
CHECK_SCRIPT="$REPO_ROOT/scripts/011_check_aliases_functions_conflicts.sh"
REPORT="$REPO_ROOT/docs/ALIASES_FUNCTIONS_CONFLICTS_REPORT.md"

echo "Running alias/function conflicts checker test..."

if [ ! -x "$CHECK_SCRIPT" ]; then
    echo "FAIL: check script is not executable: $CHECK_SCRIPT"
    exit 1
fi

# Run the checker (it may exit non-zero if conflicts exist) — that's fine
bash "$CHECK_SCRIPT" "$REPO_ROOT/assets" || true

if [ -f "$REPORT" ]; then
    echo "PASS: Report generated at $REPORT"
    # Basic sanity check for header
    if grep -q "Aliases & Functions Conflicts Report" "$REPORT"; then
        echo "PASS: Report looks valid"
        exit 0
    else
        echo "FAIL: Report header not found"
        exit 1
    fi
else
    echo "FAIL: Report not generated: $REPORT"
    exit 1
fi
