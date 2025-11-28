#!/bin/bash

# Formatting script for machinit
# Requires shfmt and black

echo "Formatting Shell Scripts..."
if command -v shfmt &> /dev/null; then
    # -i 4: Indent with 4 spaces
    # -ci: Case indent
    find "$(dirname "$0")/.." -name "*.sh" -not -path "*/node_modules/*" -print0 | xargs -0 shfmt -w -i 4 -ci
    echo "Shell scripts formatted."
else
    echo "Warning: shfmt is not installed."
    echo "Install it with: brew install shfmt"
fi

echo "Formatting Python Scripts..."
if command -v black &> /dev/null; then
    black "$(dirname "$0")/.." --exclude "/(node_modules|venv|\.git|__pycache__)/"
    echo "Python scripts formatted."
else
    echo "Warning: black is not installed."
    echo "Install it with: pip3 install black"
fi
