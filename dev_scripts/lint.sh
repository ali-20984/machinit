#!/bin/bash

# Linting script for machinit
# Requires shellcheck to be installed

echo "Running ShellCheck..."

if ! command -v shellcheck &> /dev/null; then
    echo "Error: shellcheck is not installed."
    echo "Install it with: brew install shellcheck"
    exit 1
fi

# Find all .sh files and run shellcheck
# Exclude SC1091 (Not following sourced files) as we source utils.sh dynamically
# Exclude SC2155 (Declare and assign separately) which is common in these scripts
# Search from the project root (parent of dev_scripts)
find "$(dirname "$0")/.." -name "*.sh" -not -path "*/node_modules/*" -print0 | xargs -0 shellcheck -e SC1091,SC2155

SHELLCHECK_EXIT=$?

echo "Running Python Linting..."
if command -v flake8 &> /dev/null; then
    flake8 "$(dirname "$0")/.." --exclude=node_modules,venv,.git,__pycache__
    FLAKE8_EXIT=$?
else
    echo "Warning: flake8 is not installed. Skipping Python linting."
    echo "Install it with: pip3 install flake8"
    FLAKE8_EXIT=0
fi

if [ $SHELLCHECK_EXIT -eq 0 ] && [ $FLAKE8_EXIT -eq 0 ]; then
    echo "Linting passed successfully!"
else
    echo "Linting failed."
    exit 1
fi
