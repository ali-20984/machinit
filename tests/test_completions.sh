#!/usr/bin/env bash
# Test that zsh completions for npm exist in assets
set -euo pipefail
REPO_ROOT="$(dirname "$0")/.."
COMPLETION_FILE="$REPO_ROOT/assets/completions/_npm"

echo "Running completions test..."

if [ -f "$COMPLETION_FILE" ]; then
    echo "PASS: completion file present: $COMPLETION_FILE"
    if grep -q "_describe 'npm command' commands" "$COMPLETION_FILE"; then
        echo "PASS: completion script contains expected helper list"
        exit 0
    else
        echo "FAIL: completion script missing expected content"; exit 2
    fi
else
    echo "FAIL: completion file not found: $COMPLETION_FILE"; exit 2
fi
