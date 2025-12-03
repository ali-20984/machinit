#!/usr/bin/env bash
#
# Script: 046_configure_iterm2.sh
# Description: Install or import iTerm2 color presets based on the selected theme.
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_config "iTerm2 Theme"

THEME_NAME=$(get_config "appearance.terminal_theme")
if [ -z "$THEME_NAME" ]; then
    THEME_NAME="shades_of_fire"
fi

THEME_FILE="$(dirname "$(dirname "$0")")/assets/themes/${THEME_NAME}.itermcolors"

if [ ! -f "$THEME_FILE" ]; then
    print_warning "iTerm2 theme file not found: $THEME_FILE — nothing to import"
    exit 0
fi

# Importing an .itermcolors file is done by opening it; iTerm2 registers the preset when
# it is opened. Respect DRY_RUN to avoid side effects in CI.
if [ "$DRY_RUN" = true ]; then
    print_dry_run "Open $THEME_FILE (would import into iTerm2)"
    exit 0
fi

if command -v open >/dev/null 2>&1; then
    print_action "Importing iTerm2 theme: ${THEME_NAME}"
    open "$THEME_FILE"
    print_success "Opened $THEME_FILE — if iTerm2 is installed it should register this preset"
else
    print_error "Cannot import iTerm2 preset (no 'open' command)"
fi

exit 0
