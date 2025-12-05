#!/bin/bash
# Validate that scripts/052_configure_finder_and_sidebar.sh attempts to use
# mysides when --use-mysides is passed (dry-run). Accept either an explicit
# "Adding ... using mysides" message or a "mysides not found" notice.
set -euo pipefail

SCRIPT=scripts/052_configure_finder_and_sidebar.sh

echo "Testing Finder script --use-mysides path (dry-run)..."

OUT=$(DRY_RUN=true "$SCRIPT" --add-sidebar-only --use-mysides 2>&1 || true)

if echo "$OUT" | grep -q "mysides"; then
    echo "PASS: script attempted or detected mysides when --use-mysides was requested"
    exit 0
else
    echo "FAIL: script did not mention mysides when --use-mysides was requested" >&2
    echo "$OUT" >&2
    exit 1
fi
