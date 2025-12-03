#!/usr/bin/env bash
# Quick CI-style tests for new UI scripts / flags (non-destructive: use DRY_RUN)
set -euo pipefail
FAILED=0
PROJECT_ROOT="$(dirname "$0")/.."
SCRIPTS_DIR="$PROJECT_ROOT/scripts"
INSTALL="$PROJECT_ROOT/install.sh"
UTILS="$SCRIPTS_DIR/utils.sh"
RESTART_SCRIPT="$SCRIPTS_DIR/999_restart_apps.sh"
FINDER_SCRIPT="$SCRIPTS_DIR/052_configure_finder_and_sidebar.sh"

echo "Running UI/flags CI tests (dry-run / non-destructive checks)"

# Test 1: utils.sh defines set_user_default
echo "Test 1: set_user_default helper present"
if grep -q "function set_user_default" "$UTILS"; then
    echo "PASS: set_user_default found in utils.sh"
else
    echo "FAIL: set_user_default not found in utils.sh"
    FAILED=1
fi

# Test 2: restart script accepts --yes and exits successfully (dry-run)
echo "Test 2: restart script --yes handled in DRY_RUN"
if DRY_RUN=true "$RESTART_SCRIPT" --yes >/dev/null 2>&1; then
    echo "PASS: restart script accepted --yes in DRY_RUN"
else
    echo "FAIL: restart script --yes returned non-zero"
    FAILED=1
fi

# Test 3: install.sh --run-only 1 --dry-run runs single script and exits with expected message
echo "Test 3: install.sh --run-only 1 --dry-run messaging"
chmod +x "$INSTALL" || true
OUT=$("$INSTALL" --run-only 1 --dry-run 2>&1 || true)
if echo "$OUT" | grep -q "Completed run-only script at index 1"; then
    echo "PASS: install.sh run-only printed completion message"
else
    echo "FAIL: install.sh run-only didn't print expected completion message"
    echo "--- output ---"
    echo "$OUT"
    FAILED=1
fi

# Test 4: install.sh --run-only 1 --restart-ui --dry-run triggers restart step invocation
echo "Test 4: install.sh --run-only 1 --restart-ui --dry-run triggers restart invocation"
OUT2=$("$INSTALL" --run-only 1 --restart-ui --dry-run 2>&1 || true)
if echo "$OUT2" | grep -F -- "--restart-ui requested"; then
    echo "PASS: install.sh --restart-ui reported it will run the restart script"
else
    echo "FAIL: install.sh --restart-ui did not report restart invocation"
    echo "--- output ---"
    echo "$OUT2"
    FAILED=1
fi

# Test 5: Finder script contains verification block and uses set_user_default
echo "Test 5: Finder script contains verification and per-user writes"
if grep -q "Verify Finder settings" "$FINDER_SCRIPT" && grep -q "set_user_default com.apple.finder NewWindowTarget" "$FINDER_SCRIPT"; then
    echo "PASS: Finder script includes verification and set_user_default usage"
else
    echo "FAIL: Finder script missing verification or set_user_default usage"
    FAILED=1
fi

if [ $FAILED -eq 0 ]; then
    echo "All UI/flags CI tests passed."
    exit 0
else
    echo "Some UI/flags CI tests failed."
    exit 1
fi
