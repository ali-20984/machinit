#!/bin/bash

# Extended test suite for utils.sh
source "$(dirname "$0")/../scripts/utils.sh"

FAILED=0

echo "Running Extended Utils Tests..."

# Test 1: Print functions should not fail
echo "Test 1: Print functions"
if print_success "Success message" >/dev/null; then
    echo "PASS: print_success"
else
    echo "FAIL: print_success"
    FAILED=1
fi

if print_error "Error message" >/dev/null; then
    echo "PASS: print_error"
else
    echo "FAIL: print_error"
    FAILED=1
fi

if print_info "Info message" >/dev/null; then
    echo "PASS: print_info"
else
    echo "FAIL: print_info"
    FAILED=1
fi

# Test 2: Execute with special characters
echo "Test 2: Execute with special chars"
export DRY_RUN=false
OUTPUT=$(execute bash -c "echo 'hello world' | tr 'a-z' 'A-Z'")
if [ "$OUTPUT" == "HELLO WORLD" ]; then
    echo "PASS: execute pipe"
else
    echo "FAIL: execute pipe. Got: '$OUTPUT'"
    FAILED=1
fi

# Test 3: Check command logic
echo "Test 3: Check command logic"
if check_command "bash"; then
    echo "PASS: check_command bash (exists)"
else
    echo "FAIL: check_command bash (exists)"
    FAILED=1
fi

if ! check_command "this_command_should_not_exist_12345"; then
    echo "PASS: check_command missing (correctly failed)"
else
    echo "FAIL: check_command missing (unexpectedly succeeded)"
    FAILED=1
fi

if [ $FAILED -eq 0 ]; then
    echo "All extended utils tests passed."
    exit 0
else
    echo "Some extended utils tests failed."
    exit 1
fi
