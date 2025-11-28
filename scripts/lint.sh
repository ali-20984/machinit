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
find . -name "*.sh" -print0 | xargs -0 shellcheck -e SC1091,SC2155

if [ $? -eq 0 ]; then
    echo "Linting passed successfully!"
else
    echo "Linting failed."
    exit 1
fi
