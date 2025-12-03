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

# Test 6: set_user_default supports array values (DRY_RUN)
echo "Test 6: set_user_default handles array type in DRY_RUN"
OUT3=$(DRY_RUN=true bash -c 'source "$PWD/scripts/utils.sh"; set_user_default com.example.test Test array one two three' 2>&1 || true)
if echo "$OUT3" | grep -q "\[DRY RUN\]"; then
    echo "PASS: set_user_default printed DRY RUN for array write"
else
    echo "FAIL: set_user_default did not behave as DRY_RUN for array (output below):"
    echo "$OUT3"
    FAILED=1
fi

# Test 7: Finder script sets collapsed key for iCloud when configured
echo "Test 7: Finder script attempts to set SidebarICloudDriveCollapsed"
if grep -q "SidebarICloudDriveCollapsed" "$FINDER_SCRIPT"; then
    echo "PASS: Finder script includes SidebarICloudDriveCollapsed handling"
else
    echo "FAIL: Finder script does not handle SidebarICloudDriveCollapsed"
    FAILED=1
fi

# Test 8: aliases are present only in assets/.aliases
echo "Test 8: alias placement checks"
ALIASES_FILE="$PROJECT_ROOT/assets/.aliases"
FUNCTIONS_FILE="$PROJECT_ROOT/assets/.functions"
for a in zshconf projects repos qfind lsock cd.. '.....'; do
    if grep -q "alias $a" "$ALIASES_FILE"; then
        echo "PASS: alias $a present in .aliases"
    else
        echo "FAIL: alias $a missing from .aliases"
        FAILED=1
    fi
    if grep -q "alias $a" "$FUNCTIONS_FILE"; then
        echo "FAIL: alias $a wrongly present in .functions"
        FAILED=1
    else
        echo "PASS: alias $a not in .functions"
    fi
done

# Verify repos alias matches projects
echo "Test 10: repos alias equals projects"
if grep -q '^alias projects="cd ~/Projects"' "$ALIASES_FILE" && grep -q '^alias repos="cd ~/Projects"' "$ALIASES_FILE"; then
    echo "PASS: repos equals projects"
else
    echo "FAIL: repos and projects aliases differ"
    FAILED=1
fi

# Test 11: recent() function exists in .functions
echo "Test 11: recent() present"
if grep -q "recent()" "$FUNCTIONS_FILE"; then
    echo "PASS: recent function found in .functions"
else
    echo "FAIL: recent function missing in .functions"
    FAILED=1
fi

# Test 11b: recent() supports indices, -n and pattern matching (dry-run check in source)
echo "Test 11b: recent() supports numeric index and pattern"
if grep -q "stat -f%mt" "$FUNCTIONS_FILE" && grep -q -- "-n" "$FUNCTIONS_FILE" && grep -q "basename" "$FUNCTIONS_FILE"; then
    echo "PASS: recent() appears to support numeric indices and pattern matching"
else
    echo "FAIL: recent() doesn't look like it supports indices/patterns"
    FAILED=1
fi

# Test 9: install.sh contains a single RESTART_UI definition
echo "Test 9: install.sh single RESTART_UI check"
count=$(grep -o "RESTART_UI=false" "$INSTALL" | wc -l | xargs)
if [ "$count" -eq 1 ]; then
    echo "PASS: single RESTART_UI definition found"
else
    echo "FAIL: expected 1 RESTART_UI definition, found $count"
    FAILED=1
fi

# Test 12: ll implementation is robust (no hard-coded homebrew gnubin path)
echo "Test 12: ll is defined and does not hard-code a gnubin path"
ALIASES_FILE="$PROJECT_ROOT/assets/.aliases"
if grep -q "ll()" "$ALIASES_FILE" || grep -q "alias ll=" "$ALIASES_FILE"; then
    echo "PASS: ll is defined in .aliases"
else
    echo "FAIL: ll is not defined in .aliases"
    FAILED=1
fi

# Test 13: myip function exists and references multiple fallbacks
echo "Test 13: myip() present and checks multiple services"
if grep -q "myip()" "$ALIASES_FILE" && (grep -q "icanhazip" "$ALIASES_FILE" || grep -q "checkip.amazonaws.com" "$ALIASES_FILE"); then
    echo "PASS: myip function exists and contains public-IP fallbacks"
else
    echo "FAIL: myip function missing or lacks known services (icanhazip/checkip.amazonaws.com)"
    FAILED=1
fi

# Test 14: ni alias exists for npm install
echo "Test 14: ni alias present"
if grep -q '^alias ni="npm install"' "$ALIASES_FILE"; then
    echo "PASS: ni alias exists"
else
    echo "FAIL: ni alias missing"
    FAILED=1
fi

if grep -q "/opt/homebrew/opt/coreutils/libexec/gnubin/ls" "$ALIASES_FILE"; then
    echo "FAIL: ll uses a hard-coded Homebrew gnubin path"
    FAILED=1
else
    echo "PASS: ll does not hard-code Homebrew gnubin path"
fi

if [ $FAILED -eq 0 ]; then
    echo "All UI/flags CI tests passed."
    exit 0
else
    echo "Some UI/flags CI tests failed."
    exit 1
fi
