#!/bin/bash
# Ensure install.sh supports --pin-sidebar and exits after pinning (dry-run)
set -euo pipefail

INSTALL=./install.sh

echo "Testing install.sh --pin-sidebar (dry-run)..."

OUT=$("$INSTALL" --pin-sidebar --dry-run 2>&1 || true)

if echo "$OUT" | grep -q "Pinning Finder sidebar items only" && echo "$OUT" | grep -q "Finder sidebar pinning complete. Exiting."; then
    echo "PASS: install.sh --pin-sidebar runs the finder script and exits"
    exit 0
else
    echo "FAIL: expected messages not found in output:" >&2
    echo "$OUT" >&2
    exit 1
fi
