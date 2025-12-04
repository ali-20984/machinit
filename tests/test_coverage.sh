#!/usr/bin/env bash
# Run coverage for the project's Python tests if coverage.py is available
set -euo pipefail

REPO_ROOT="$(dirname "$0")/.."
COV_BIN="$(command -v coverage || true)"

echo "Running coverage test..."

if [ -z "$COV_BIN" ]; then
  echo "SKIP: coverage.py not installed, skipping coverage test.";
  exit 0
fi

# run coverage for the tests directory and ensure a report is generated
cd "$REPO_ROOT"
coverage run -m pytest -q tests/ || { echo "FAIL: pytest under coverage failed"; exit 1; }
coverage report -m || { echo "FAIL: coverage.report failed"; exit 1; }

echo "PASS: coverage report generated"
exit 0
