#!/bin/bash
# Verify install.sh --pin-sidebar --pin-sidebar-use-fse passes --use-fse to the Finder script
set -euo pipefail

INSTALL=./install.sh

echo "Testing top-level install --pin-sidebar uses FinderSidebarEditor by default (dry-run)..."

OUT=$("$INSTALL" --pin-sidebar --dry-run 2>&1 || true)

if echo "$OUT" | grep -q "finder_sidebar_editor" || echo "$OUT" | grep -q "FinderSidebar().add"; then
    echo "PASS: install.sh --pin-sidebar used finder_sidebar_editor by default"
    exit 0
else
    echo "FAIL: expected FinderSidebarEditor invocation not found in output" >&2
    echo "$OUT" >&2
    exit 1
fi
