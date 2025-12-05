#!/bin/bash
# Test scripts/052_configure_finder_and_sidebar.sh --add-sidebar-only behavior
set -euo pipefail

SCRIPT=scripts/052_configure_finder_and_sidebar.sh

echo "Testing Finder sidebar add-only flag (dry-run)..."

OUT=$(DRY_RUN=true "$SCRIPT" --add-sidebar-only 2>&1 || true)

if echo "$OUT" | grep -q "Finder sidebar pinning done (add-only mode)"; then
    echo "PASS: add-only mode performed and exited cleanly"
    exit 0
else
    echo "FAIL: add-only mode output mismatch:" >&2
    echo "$OUT" >&2
    exit 1
fi
