#!/bin/bash

# Formatting script for machinit
# Requires shfmt and black

echo "Formatting code (shfmt / black / pre-commit)..."
ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd -P)

if command -v pre-commit &>/dev/null; then
    echo "Running pre-commit hooks across all files..."
    pre-commit run --all-files || true
else
    echo "pre-commit not installed; falling back to direct formatters."
fi

echo "Formatting Shell Scripts..."
if command -v shfmt &>/dev/null; then
    # -i 4: Indent with 4 spaces
    # -ci: Case indent
    find "$ROOT_DIR" -name "*.sh" -not -path "*/node_modules/*" -print0 | xargs -0 shfmt -w -i 4 -ci || true
    echo "Shell scripts formatted."
else
    echo "Warning: shfmt is not installed."
    echo "Install it with: brew install shfmt or pipx/pre-commit (recommended)"
fi

echo "Formatting Python Scripts..."
if command -v black &>/dev/null; then
    python3 -m black "$ROOT_DIR" --exclude "/(node_modules|venv|\.git|__pycache__)/" || true
    echo "Python scripts formatted."
else
    echo "Warning: black is not installed."
    echo "Install it with: pip3 install black or pipx install black"
fi
