#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT="$(dirname "$0")/.."
SCRIPT="$PROJECT_ROOT/scripts/051_configure_system_ui_ux.sh"

echo "Running system accent tests (dry-run checks)"
FAILED=0

if grep -q "AppleAccentColor" "$SCRIPT"; then
    echo "PASS: script contains AppleAccentColor change"
else
    echo "FAIL: missing AppleAccentColor write"
    FAILED=1
fi

if grep -q "AppleHighlightColor" "$SCRIPT"; then
    echo "PASS: script contains AppleHighlightColor write"
else
    echo "FAIL: missing AppleHighlightColor write"
    FAILED=1
fi

if [ $FAILED -eq 0 ]; then
    echo "System accent tests passed."
    exit 0
else
    echo "Some system accent tests failed."
    exit 1
fi
