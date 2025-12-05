#!/bin/bash
# Verify install.sh --pin-sidebar --pin-sidebar-use-mysides forwards --use-mysides to Finder script
set -euo pipefail

INSTALL=./install.sh

echo "Testing top-level install --pin-sidebar with --pin-sidebar-use-mysides (dry-run)..."

OUT=$("$INSTALL" --pin-sidebar --pin-sidebar-use-mysides --dry-run 2>&1 || true)

if echo "$OUT" | grep -q "mysides"; then
    echo "PASS: install.sh --pin-sidebar forwarded --use-mysides to Finder script"
    exit 0
else
    echo "FAIL: expected mysides invocation or notice not found in output" >&2
    echo "$OUT" >&2
    exit 1
fi
