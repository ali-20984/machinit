#!/bin/bash
# Verify Dock script prefers actual Documents/Projects folder and resolves
# symlinks instead of pinning a symlink path
set -euo pipefail

SCRIPT=scripts/044_configure_dock_apps.sh

echo "Running dock projects pin test..."

if grep -q "Prefer the canonical Documents/Projects" "$SCRIPT"; then
    echo "PASS: script documents preference for Documents/Projects"
else
    echo "FAIL: script does not indicate a preference for Documents/Projects"
    exit 1
fi

# Also ensure it attempts to resolve symlinks using python3.realpath or similar
if grep -q "python3 -c 'import os,sys;print(os.path.realpath" "$SCRIPT" || grep -q "readlink \"\$\{ORIGINAL_HOME\}/Projects\"" "$SCRIPT"; then
    echo "PASS: script attempts to resolve symlink to real path"
else
    echo "FAIL: script does not resolve symlink when pinning Projects"
    exit 1
fi
