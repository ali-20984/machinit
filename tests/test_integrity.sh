#!/bin/bash

# Integrity checks for the project structure
FAILED=0

PROJECT_ROOT="$(dirname "$0")/.."
INSTALL_SCRIPT="$PROJECT_ROOT/install.sh"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"

echo "Running Integrity Tests..."

# Test 1: Check if PARSER_SCRIPT path in install.sh is valid
echo "Test 1: Check PARSER_SCRIPT path"
# Extract the line defining PARSER_SCRIPT
PARSER_LINE=$(grep "PARSER_SCRIPT=" "$INSTALL_SCRIPT")
# Extract the value (remove quotes)
PARSER_PATH=$(echo "$PARSER_LINE" | cut -d'=' -f2 | tr -d '"')
# Resolve absolute path (assuming it's relative to install.sh location)
# Note: install.sh uses relative path.
FULL_PARSER_PATH="$PROJECT_ROOT/$PARSER_PATH"

if [ -f "$FULL_PARSER_PATH" ]; then
    echo "PASS: Parser script found at $PARSER_PATH"
else
    echo "FAIL: Parser script NOT found at $PARSER_PATH (Resolved: $FULL_PARSER_PATH)"
    FAILED=1
fi

# Test 2: Check if all scripts in scripts/ are executable
echo "Test 2: Check script permissions"
NON_EXEC_SCRIPTS=$(find "$SCRIPTS_DIR" -name "*.sh" ! -perm -u+x)
if [ -z "$NON_EXEC_SCRIPTS" ]; then
    echo "PASS: All scripts are executable"
else
    echo "FAIL: The following scripts are not executable:"
    echo "$NON_EXEC_SCRIPTS"
    FAILED=1
fi

# Test 3: Check config.toml validity
echo "Test 3: Check config.toml validity"
if command -v python3 &> /dev/null; then
    if python3 -c "import tomllib; f=open('$PROJECT_ROOT/config.toml','rb'); tomllib.load(f); f.close()" 2>/dev/null; then
        echo "PASS: config.toml is valid"
    else
        echo "FAIL: config.toml is invalid"
        FAILED=1
    fi
else
    echo "SKIP: python3 not found for TOML check"
fi

if [ $FAILED -eq 0 ]; then
    echo "All integrity tests passed."
    exit 0
else
    echo "Some integrity tests failed."
    exit 1
fi
