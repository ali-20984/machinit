#!/bin/bash

# Master test runner
# Runs all tests in the tests/ directory

TEST_DIR="$(dirname "$0")/../tests"
FAILED=0

echo "Running Shell Tests..."
if [ -f "$TEST_DIR/test_utils.sh" ]; then
    bash "$TEST_DIR/test_utils.sh"
    if [ $? -ne 0 ]; then
        echo "✗ test_utils.sh failed"
        FAILED=1
    else
        echo "✓ test_utils.sh passed"
    fi
fi

echo "--------------------------------------------------"

echo "Running Python Tests..."
if [ -f "$TEST_DIR/test_config_parser.py" ]; then
    python3 "$TEST_DIR/test_config_parser.py"
    if [ $? -ne 0 ]; then
        echo "✗ test_config_parser.py failed"
        FAILED=1
    else
        echo "✓ test_config_parser.py passed"
    fi
fi

echo "--------------------------------------------------"

if [ $FAILED -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "Some tests failed."
    exit 1
fi
