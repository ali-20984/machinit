#!/usr/bin/env bash
# Test that zsh completions for npm exist in assets
set -euo pipefail
REPO_ROOT="$(dirname "$0")/.."
CANDIDATES=("$REPO_ROOT/assets/completions/_npm" "$REPO_ROOT/assets/completions/_yarn")

echo "Running completions test..."

for f in "${CANDIDATES[@]}"; do
    if [ -f "$f" ]; then
        echo "PASS: completion file present: $f"
        if grep -Eq "_describe '.* command' commands" "$f"; then
            echo "PASS: completion script contains expected helper list"
        else
            echo "FAIL: completion script missing expected content: $f"; exit 2
        fi
    else
        echo "FAIL: completion file not found: $f"; exit 2
    fi
done
exit 0
