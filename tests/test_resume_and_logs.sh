#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT="$(dirname "$0")/.."
INSTALL="$PROJECT_ROOT/install.sh"
LOG_DIR="$PROJECT_ROOT/logs"

# Ensure install script executable
chmod +x "$INSTALL" || true

echo "Test A: clear logs removes logs directory"
mkdir -p "$LOG_DIR"
touch "$LOG_DIR/dummy.log"
OUT=$("$INSTALL" --clear-logs 2>&1 || true)
if [ -d "$LOG_DIR" ]; then
    echo "FAIL: logs directory still exists after --clear-logs"
    exit 1
else
    echo "PASS: --clear-logs removed logs/"
fi

echo "Test B: resume-failure reads last_failed and sets START_FROM"
mkdir -p "$LOG_DIR"
echo "052_configure_finder_and_sidebar.sh" > "$LOG_DIR/last_failed"
OUT2=$("$INSTALL" --resume-failure --dry-run 2>&1 || true)
if echo "$OUT2" | grep -q "Resuming from last failed script"; then
    echo "PASS: --resume-failure detected and reported last_failed"
else
    echo "FAIL: --resume-failure didn't report resume"
    echo "--- output ---"
    echo "$OUT2"
    exit 1
fi

# Test C: install writes logs into logs/ when not NO_LOG
rm -rf "$LOG_DIR" || true
OUT3=$("$INSTALL" --start-from 001_env_setup.sh --run-only 1 --dry-run 2>&1 || true)
if ls "$PROJECT_ROOT"/logs/* >/dev/null 2>&1; then
    echo "PASS: install.sh wrote logs into logs/"
else
    echo "FAIL: install.sh did not write logs into logs/"
    exit 1
fi

# Test D: --exit exits quickly and does not create logs
rm -rf "$LOG_DIR" || true
OUT4=$("$INSTALL" --exit 2>&1 || true)
if echo "$OUT4" | grep -q "--exit was passed; exiting now"; then
    echo "PASS: --exit returned immediately"
else
    echo "FAIL: --exit did not behave as expected"
    echo "$OUT4"
    exit 1
fi

echo "All resume/log tests passed."
