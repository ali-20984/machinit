#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT="$(dirname "$0")/.."
TERM_SCRIPT="$PROJECT_ROOT/scripts/046_configure_terminal.sh"

echo "Running Terminal theme tests (dry-run checks)"
FAILED=0

# Test 1: Check the script mentions Shades of Fire
if grep -q "Shades of Fire" "$TERM_SCRIPT"; then
    echo "PASS: 046_configure_terminal.sh contains 'Shades of Fire' markers"
else
    echo "FAIL: 046_configure_terminal.sh missing 'Shades of Fire' markers"
    FAILED=1
fi

# Test 2: Ensure it writes a prompt block into .zshrc (dry-run check)
if grep -q "# Shades of Fire prompt" "$TERM_SCRIPT"; then
    echo "PASS: Terminal script will add Shades of Fire prompt block to ~/.zshrc"
else
    echo "FAIL: Terminal script does not add prompt block"
    FAILED=1
fi

# Test 3: Check config.toml contains an appearance.terminal_theme default
if grep -q "\[appearance\]" "$PROJECT_ROOT/config.toml" && grep -q "terminal_theme" "$PROJECT_ROOT/config.toml"; then
    echo "PASS: config.toml contains an appearance.terminal_theme setting"
else
    echo "FAIL: config.toml missing appearance.terminal_theme"
    FAILED=1
fi

# Test 4: Ensure an iTerm2 script exists and theme files are present
ITERM_SCRIPT="$PROJECT_ROOT/scripts/046_configure_iterm2.sh"
if [ -f "$ITERM_SCRIPT" ]; then
    echo "PASS: iTerm2 config script present"
else
    echo "FAIL: iTerm2 config script missing"
    FAILED=1
fi

if [ -f "$PROJECT_ROOT/assets/themes/shades_of_fire.itermcolors" ] && [ -f "$PROJECT_ROOT/assets/themes/charcoal.itermcolors" ]; then
    echo "PASS: iTerm2 theme files exist (shades_of_fire and charcoal)"
else
    echo "FAIL: Missing iTerm2 theme files under assets/themes"
    FAILED=1
fi

if [ $FAILED -eq 0 ]; then
    echo "Terminal theme tests passed."
    exit 0
else
    echo "Terminal theme tests failed."
    exit 1
fi
