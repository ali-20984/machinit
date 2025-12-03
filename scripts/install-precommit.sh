#!/usr/bin/env bash
set -euo pipefail

echo "Installing pre-commit and enabling git hooks..."
if ! command -v python3 &>/dev/null; then
  echo "python3 is required. Please install Python 3." >&2
  exit 1
fi

python3 -m pip install --user --upgrade pre-commit || python3 -m pip install --upgrade pre-commit

echo "Running pre-commit install..."
if command -v pre-commit &>/dev/null; then
  pre-commit install
  echo "pre-commit installed. You can run 'pre-commit run --all-files' to format existing files."
else
  echo "pre-commit not found on PATH after pip install. You may need to add ~/.local/bin to your PATH." >&2
  exit 1
fi
