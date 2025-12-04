#!/usr/bin/env bash
# Run the pytest runner for the project's Python tests when pytest is available
set -euo pipefail

REPO_ROOT="$(dirname "$0")/.."
PYTEST_BIN="$(command -v pytest || true)"

echo "Running pytest runner test..."

if [ -z "$PYTEST_BIN" ]; then
  echo "SKIP: pytest not installed, skipping pytest-runner test.";
  exit 0
fi

# run pytest on all python test files in tests (non-recursive)
if pytest -q "$REPO_ROOT/tests"; then
  echo "PASS: pytest run completed successfully"
  exit 0
else
  echo "FAIL: pytest reported failures"; exit 1
fi
