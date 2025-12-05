#!/bin/bash
# Validate that scripts/052_configure_finder_and_sidebar.sh attempts to use
# the FinderSidebarEditor Python module when USE_FSE is true (dry-run).
set -euo pipefail

SCRIPT=scripts/052_configure_finder_and_sidebar.sh

echo "Testing Finder script USE_FSE path (dry-run)..."

OUT=$(DRY_RUN=true USE_FSE=true "$SCRIPT" --add-sidebar-only 2>&1 || true)

if echo "$OUT" | grep -q "FinderSidebarEditor" || echo "$OUT" | grep -q "FinderSidebar().add"; then
    echo "PASS: script attempted to call FinderSidebarEditor when USE_FSE=true"
    exit 0
else
    echo "FAIL: script did not attempt to use FinderSidebarEditor" >&2
    echo "$OUT" >&2
    exit 1
fi
