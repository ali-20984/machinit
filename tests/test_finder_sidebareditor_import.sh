#!/bin/bash
# Ensure the new bundled finder_sidebar_editor.py is importable by python3
set -euo pipefail

echo "Testing finder_sidebar_editor importability..."

OUT=$(python3 -c 'import sys; from finder_sidebar_editor import FinderSidebar; print("OK")' 2>&1 || true)

if echo "$OUT" | grep -q "OK"; then
    echo "PASS: finder_sidebar_editor imported successfully"
    exit 0
else
    echo "FAIL: finder_sidebar_editor import failed" >&2
    echo "$OUT" >&2
    exit 1
fi
