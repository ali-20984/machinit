#!/bin/bash

# Linting script for machinit
# Requires shellcheck to be installed

echo "Running ShellCheck..."

if ! command -v shellcheck &>/dev/null; then
    echo "Error: shellcheck is not installed."
    echo "Install it with: brew install shellcheck"
    exit 1
fi

# Find all .sh files and run shellcheck. Only treat 'error' severity as a failure
# so that informational warnings (SC2034, SC2038, etc.) don't cause lint to fail.
# Exclude SC1091 (Not following sourced files) as we source utils.sh dynamically
# Exclude SC2155 (Declare and assign separately) which is common in these scripts
# Search from the project root (parent of dev_scripts)
find "$(dirname "$0")/.." -name "*.sh" -not -path "*/node_modules/*" -print0 | \
    xargs -0 shellcheck --severity=error -e SC1091,SC2155

SHELLCHECK_EXIT=$?

echo "Running Python Linting..."
if command -v flake8 &>/dev/null; then
    # exclude common virtualenv paths — both 'venv' and '.venv' can appear
    # Allow longer lines in Python tools (URLs and helper scripts) to reduce
    # noise from long import URLs and generated content. Set 120 as a practical
    # compromise between readability and long URL lines.
    flake8 "$(dirname "$0")/.." --exclude=node_modules,venv,.venv,.git,__pycache__ --max-line-length=120
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
