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

# Test 17: install.sh supports --update-shell and respects dry-run
echo "Test 17: install.sh --update-shell --dry-run exits after updating aliases/functions"
OUT4=$("$INSTALL" --update-shell --dry-run 2>&1 || true)
if echo "$OUT4" | grep -q "Updating aliases and functions"; then
    echo "PASS: install.sh accepted --update-shell and attempted to update shell files"
else
    echo "FAIL: install.sh --update-shell didn't print expected message"
    echo "--- output ---"
    echo "$OUT4"
    FAILED=1
fi

# Test 20: install.sh --reset-finder-view --dry-run should run finder reset only
echo "Test 20: install.sh --reset-finder-view --dry-run runs Finder reset and exits"
OUT5=$("$INSTALL" --reset-finder-view --dry-run 2>&1 || true)
if echo "$OUT5" | grep -q "Resetting Finder view only" && echo "$OUT5" | grep -q "Removing per-folder \.DS_Store files"; then
    echo "PASS: install.sh --reset-finder-view attempted Finder reset (dry-run)"
else
    echo "FAIL: install.sh --reset-finder-view behavior not detected"
    echo "--- output ---"
    echo "$OUT5"
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
    if grep -F -q "alias $a" "$ALIASES_FILE"; then
        echo "PASS: alias $a present in .aliases"
    else
        echo "FAIL: alias $a missing from .aliases"
        FAILED=1
    fi
    if grep -F -q "alias $a" "$FUNCTIONS_FILE"; then
        echo "FAIL: alias $a wrongly present in .functions"
        FAILED=1
    else
        echo "PASS: alias $a not in .functions"
    fi
done

# Test 14g: dl alias points to Downloads
echo "Test 14g: dl alias present"
if grep -q '^alias dl="cd ~/Downloads"' "$ALIASES_FILE"; then
    echo "PASS: dl alias exists"
else
    echo "FAIL: dl alias missing"
    FAILED=1
fi

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
FUNCTIONS_FILE="$PROJECT_ROOT/assets/.functions"
if grep -q "ll()" "$FUNCTIONS_FILE" || grep -q "alias ll=" "$ALIASES_FILE"; then
    echo "PASS: ll is defined in .functions or alias in .aliases"
else
    echo "FAIL: ll is not defined in .aliases"
    FAILED=1
fi

# Test 13: myip function exists and references multiple fallbacks (defaults to Amazon checkip)
echo "Test 13: myip() present and checks multiple services (default prefers Amazon)"
if grep -q "myip()" "$FUNCTIONS_FILE" && grep -q "checkip.amazonaws.com" "$FUNCTIONS_FILE"; then
    echo "PASS: myip function exists and prefers checkip.amazonaws.com by default"
else
    echo "FAIL: myip function missing or does not prefer checkip.amazonaws.com"
    FAILED=1
fi

# Test 18: Finder script ensures List view preference is configured
echo "Test 18: Finder script sets FXPreferredViewStyle to Nlsv (List view)"
if grep -q "FXPreferredViewStyle.*Nlsv" "$FINDER_SCRIPT" || grep -q "FXPreferredViewStyle string \"Nlsv\"" "$FINDER_SCRIPT"; then
    echo "PASS: Finder script sets FXPreferredViewStyle to Nlsv"
else
    echo "FAIL: Finder script did not set FXPreferredViewStyle to Nlsv"
    FAILED=1
fi

# Test 19: Finder script supports reset flag or env var for .DS_Store cleanup
echo "Test 19: Finder script supports .DS_Store cleanup via flag/env"
if grep -Fq 'find "${ORIGINAL_HOME}"' "$FINDER_SCRIPT" && grep -Fq '.DS_Store' "$FINDER_SCRIPT"; then
    echo "PASS: Finder script contains .DS_Store cleanup logic"
else
    echo "FAIL: Finder script missing .DS_Store cleanup logic"
    FAILED=1
fi

# Test 13b: myip supports --ipv6/-6 flag
echo "Test 13b: myip supports --ipv6 or -6"
if grep -q -- "--ipv6" "$FUNCTIONS_FILE" || grep -q -- "-6" "$FUNCTIONS_FILE"; then
    echo "PASS: myip supports IPv6 flag"
else
    echo "FAIL: myip lacks --ipv6/-6 support"
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

# Test 14b: nps alias exists for npm start
echo "Test 14b: nps alias present"
if grep -q '^alias nps="npm start"' "$ALIASES_FILE"; then
    echo "PASS: nps alias exists"
else
    echo "FAIL: nps alias missing"
    FAILED=1
fi

# Test 14a: shrug uses pbcopy to copy emoticon (consistent behavior)
echo "Test 14a: shrug uses pbcopy"
if grep -q "^alias shrug=.*pbcopy" "$ALIASES_FILE"; then
    echo "PASS: shrug uses pbcopy"
else
    echo "FAIL: shrug not present or not using pbcopy"
    FAILED=1
fi

# Test 14c: wtf alias exists for dmesg
echo "Test 14c: wtf alias present"
if grep -q '^alias wtf=' "$ALIASES_FILE"; then
    echo "PASS: wtf alias exists"
else
    echo "FAIL: wtf alias missing"
    FAILED=1
fi

# Test 14d: up alias exists and contains uptime invocation
echo "Test 14d: up alias present and includes uptime"
if grep -q '^alias up=' "$ALIASES_FILE" && grep -q 'uptime' "$ALIASES_FILE"; then
    echo "PASS: up alias exists and runs uptime"
else
    echo "FAIL: up alias missing or does not include uptime"
    FAILED=1
fi

# Test 14e: tableflip & fix emoticon helpers (copy to clipboard with pbcopy)
echo "Test 14e: tableflip and fix present and copy to clipboard"
if grep -q "^alias tableflip=.*pbcopy" "$ALIASES_FILE" && grep -q "^alias fix=.*pbcopy" "$ALIASES_FILE"; then
    echo "PASS: tableflip and fix aliases exist and use pbcopy"
else
    echo "FAIL: tableflip / fix aliases are missing or don't use pbcopy"
    FAILED=1
fi

# Test 14f: entropy, void, fractal, eldritchterror
echo "Test 14f: entropy, void, fractal, eldritchterror present"
for a in entropy void fractal eldritchterror; do
    if grep -q "^alias ${a}=" "$ALIASES_FILE"; then
        echo "PASS: $a alias exists"
    else
        echo "FAIL: $a alias missing"
        FAILED=1
    fi
done

# Test 15: myip includes named shorthands (aws, icanhazip)
echo "Test 15: myip supports named services such as 'aws' and 'icanhazip'"
if grep -q "SERVICE_MAP\[aws\]" "$FUNCTIONS_FILE" && grep -q "SERVICE_MAP\[icanhazip\]" "$FUNCTIONS_FILE" && grep -q "SERVICE_MAP\[ican\]" "$FUNCTIONS_FILE"; then
    echo "PASS: myip supports named services (aws, icanhazip, ican)"
else
    echo "FAIL: myip does not include named service mappings (aws/icanhazip)"
    FAILED=1
fi

# Test 16: myip help exists
echo "Test 16: myip has a help message (--help)"
if grep -q -- "--help" "$FUNCTIONS_FILE" || grep -q -- "Usage: myip" "$FUNCTIONS_FILE"; then
    echo "PASS: myip help exists"
else
    echo "FAIL: myip help missing"
    FAILED=1
fi

if grep -q "/opt/homebrew/opt/coreutils/libexec/gnubin/ls" "$FUNCTIONS_FILE"; then
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
