#!/bin/bash

#!/usr/bin/env bash
set -euo pipefail

# Master test runner — dynamically discovers and runs tests from tests/
# Usage: dev_scripts/test.sh [--pattern <glob|regex>] [--list] [--verbose]
#   --pattern <pattern>  Only run tests whose filename matches the provided pattern
#   --list               Only show tests that would run
#   --verbose            Print commands output as they run

TEST_DIR="$(dirname "$0")/../tests"
PATTERN=""
LIST_ONLY=false
VERBOSE=false
USE_PYTEST=false

while [ "$#" -gt 0 ]; do
    case "$1" in
        --pattern)
            PATTERN="$2"
            shift 2
            ;;
        --list)
            LIST_ONLY=true
            shift
            ;;
        --pytest)
            USE_PYTEST=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        -h | --help)
            echo "Usage: $0 [--pattern <pattern>] [--list] [--verbose]"
            exit 0
            ;;
        *)
            echo "Unknown arg: $1"
            exit 2
            ;;
    esac
done

if [ ! -d "$TEST_DIR" ]; then
    echo "Tests directory not found: $TEST_DIR" >&2
    exit 2
fi

echo "Discovering tests in: $TEST_DIR"

# Find test files in tests/ (non-recursive), sort for deterministic order
while IFS= read -r entry; do
    ALL_TESTS+=("$entry")
done < <(find "$TEST_DIR" -maxdepth 1 -type f -print0 | xargs -0 -n1 basename | sort)

# Optionally filter by pattern
TESTS=()
for f in "${ALL_TESTS[@]}"; do
    # Only consider names starting with "test_"
    case "$f" in
        test_*)
            if [ -n "$PATTERN" ]; then
                if [[ "$f" =~ $PATTERN ]]; then
                    TESTS+=("$f")
                fi
            else
                TESTS+=("$f")
            fi
            ;;
        *)
            # ignore non-test files
            ;;
    esac
done

if [ ${#TESTS[@]} -eq 0 ]; then
    echo "No tests matched (pattern='$PATTERN')." >&2
    exit 2
fi

echo "Found ${#TESTS[@]} test(s):"
for t in "${TESTS[@]}"; do echo " - $t"; done

if [ "$LIST_ONLY" = true ]; then
    echo "List-only mode; not executing tests."
    exit 0
fi

FAILED=0
PASSED=0
SKIPPED=0

run_test() {
    local file="$1"
    local filepath="$TEST_DIR/$file"
    local ext="${file##*.}"

    echo "--------------------------------------------------"
    printf "Running %s" "$file"
    if [ "$VERBOSE" = true ]; then echo " (verbose)"; else echo; fi

    if [ ! -f "$filepath" ]; then
        echo "SKIP: file not found: $file"
        SKIPPED=$((SKIPPED + 1))
        return
    fi

    case "$ext" in
        sh)
            if ! bash "$filepath"; then
                echo "✗ $file failed"
                FAILED=1
                return 1
            else
                echo "✓ $file passed"
                PASSED=$((PASSED + 1))
                return 0
            fi
            ;;
        py)
            # Prefer pytest if available or when --pytest was requested
            if [ "$USE_PYTEST" = true ] || command -v pytest >/dev/null 2>&1; then
                if ! pytest -q "$filepath"; then
                    echo "✗ $file failed"
                    FAILED=1
                    return 1
                else
                    echo "✓ $file passed"
                    PASSED=$((PASSED + 1))
                    return 0
                fi
            else
                if ! python3 "$filepath"; then
                    echo "✗ $file failed"
                    FAILED=1
                    return 1
                else
                    echo "✓ $file passed"
                    PASSED=$((PASSED + 1))
                    return 0
                fi
            fi
            ;;
        *)
            echo "SKIP: unsupported test type: $file"
            SKIPPED=$((SKIPPED + 1))
            return
            ;;
    esac
}
for t in "${TESTS[@]}"; do
    if ! run_test "$t"; then
        # continue running remaining tests; failed marker handled inside run_test
        :
    fi
done

echo "--------------------------------------------------"
echo "Summary: Passed: $PASSED | Skipped: $SKIPPED | Failed: $FAILED"

if [ $FAILED -ne 0 ]; then
    echo "Some tests failed."
    exit 1
else
    echo "All tests passed!"
    exit 0
fi
