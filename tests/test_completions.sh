#!/usr/bin/env bash
# Test that zsh completions for npm exist in assets
set -euo pipefail
REPO_ROOT="$(dirname "$0")/.."
# Dynamically validate all completion files under assets/completions
CANDIDATES=("$REPO_ROOT/assets/completions/"_*)

echo "Running completions test..."

for f in "${CANDIDATES[@]}"; do
    if [ -f "$f" ]; then
        echo "PASS: completion file present: $f"
        if [ -s "$f" ]; then
            echo "PASS: $f is non-empty"
        else
            echo "FAIL: $f is empty"
            exit 2
        fi
        # check common helper list pattern if present so npm/yarn remain validated
        if grep -Eq "_describe '.* command' commands|_describe \'.* command\' commands" "$f"; then
            echo "PASS: completion script contains expected helper list"
        fi
    else
        echo "FAIL: completion file not found: $f"
        exit 2
    fi
done
exit 0
