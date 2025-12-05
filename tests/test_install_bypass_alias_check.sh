#!/bin/bash
# Ensure install.sh sets SKIP_ALIAS_CHECK during a full-run so dotfiles
# installation won't abort on conflicts when invoked via the top-level
# installer.
set -euo pipefail

INSTALL=./install.sh

echo "Running install bypass check..."

if grep -q "export SKIP_ALIAS_CHECK=1" "$INSTALL"; then
    echo "PASS: install.sh exports SKIP_ALIAS_CHECK=1 for full installers"
    exit 0
else
    echo "FAIL: install.sh does not export SKIP_ALIAS_CHECK=1 (expected for full-run installs)"
    exit 1
fi
