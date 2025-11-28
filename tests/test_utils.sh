#!/bin/bash

# Test suite for utils.sh
# Run this from the project root

source "$(dirname "$0")/../scripts/utils.sh"

FAILED=0

function assert_eq() {
    if [ "$1" != "$2" ]; then
        echo "FAIL: Expected '$2', got '$1'"
        FAILED=1
    else
        echo "PASS: '$1' == '$2'"
    fi
}

echo "Testing utils.sh..."

# Test 1: DRY_RUN behavior
echo "Test 1: DRY_RUN=true execute()"
DRY_RUN=true
OUTPUT=$(execute "echo hello")
# execute prints to stdout with color codes. We need to strip them or check for content.
# print_dry_run outputs: [DRY RUN] echo hello (with colors)
if [[ "$OUTPUT" == *"[DRY RUN] echo hello"* ]]; then
    echo "PASS: DRY_RUN execute"
else
    echo "FAIL: DRY_RUN execute. Got: $OUTPUT"
    FAILED=1
fi

# Test 2: DRY_RUN=false execute()
echo "Test 2: DRY_RUN=false execute()"
DRY_RUN=false
OUTPUT=$(execute "echo hello")
if [[ "$OUTPUT" == "hello" ]]; then
    echo "PASS: Normal execute"
else
    echo "FAIL: Normal execute. Got: $OUTPUT"
    FAILED=1
fi

# Test 3: check_command
echo "Test 3: check_command (existing)"
if check_command "ls" > /dev/null; then
    echo "PASS: check_command ls"
else
    echo "FAIL: check_command ls"
    FAILED=1
fi

echo "Test 4: check_command (missing)"
if ! check_command "nonexistentcommand123" > /dev/null; then
    echo "PASS: check_command missing"
else
    echo "FAIL: check_command missing"
    FAILED=1
fi

if [ $FAILED -eq 0 ]; then
    echo "All utils tests passed."
    exit 0
else
    echo "Some utils tests failed."
    exit 1
fi
