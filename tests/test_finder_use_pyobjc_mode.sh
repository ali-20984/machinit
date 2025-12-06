#!/bin/bash
# Validate that scripts/052_configure_finder_and_sidebar.sh attempts to use
# the pyobjc path when --use-pyobjc is passed (dry-run). Accept either a
# mention that pyobjc support was requested or the notification that pyobjc
# is not available. We mostly verify the flag is forwarded to the helper.
set -euo pipefail

SCRIPT=scripts/052_configure_finder_and_sidebar.sh

echo "Testing Finder script --use-pyobjc path (dry-run)..."

OUT=$(DRY_RUN=true "$SCRIPT" --add-sidebar-only --use-pyobjc 2>&1 || true)

if echo "$OUT" | grep -q "pyobjc"; then
    echo "PASS: script mentioned pyobjc when --use-pyobjc was requested"
    exit 0
else
    echo "FAIL: script did not mention pyobjc when --use-pyobjc was requested" >&2
    echo "$OUT" >&2
    exit 1
fi
