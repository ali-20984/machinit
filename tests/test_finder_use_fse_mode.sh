#!/bin/bash
# Validate that scripts/052_configure_finder_and_sidebar.sh attempts to use
# the bundled finder_sidebar_editor Python module by default (dry-run).
set -euo pipefail

SCRIPT=scripts/052_configure_finder_and_sidebar.sh

echo "Testing Finder script uses finder_sidebar_editor by default (dry-run)..."

OUT=$(DRY_RUN=true "$SCRIPT" --add-sidebar-only 2>&1 || true)

if echo "$OUT" | grep -q "finder_sidebar_editor" || echo "$OUT" | grep -q "FinderSidebar().add"; then
    echo "PASS: script attempted to call finder_sidebar_editor by default"
    exit 0
else
    echo "FAIL: script did not attempt to use finder_sidebar_editor by default" >&2
    echo "$OUT" >&2
    exit 1
fi
