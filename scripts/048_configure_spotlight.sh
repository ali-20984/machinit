#!/bin/bash
#
# Script: 048_configure_spotlight.sh
# Description: Configure Spotlight to index Applications only and disable web results.
# Author: supermarsx
#

source "$(dirname "$0")/utils.sh"

print_config "Spotlight"

# Function: check_status
# Description: Print a consistent success/failure marker after each grouped
#              Spotlight change so logs are easy to scan.
function check_status() {
    if [ $? -eq 0 ]; then
        echo "✓ $1"
    else
        echo "✗ Failed to: $1"
    fi
}

# Function: run_spotlight_configuration
# Description: Applies the Spotlight defaults plist ordering and disables web
#              suggestions before restarting the metadata server.
function run_spotlight_configuration() {
    execute_sudo mdutil -i on /
    defaults write com.apple.spotlight orderedItems -array \
        '{"enabled" = 1; "name" = "APPLICATIONS";}' \
        '{"enabled" = 0; "name" = "SYSTEM_PREFS";}' \
        '{"enabled" = 0; "name" = "DIRECTORIES";}' \
        '{"enabled" = 0; "name" = "PDF";}' \
        '{"enabled" = 0; "name" = "FONTS";}' \
        '{"enabled" = 0; "name" = "DOCUMENTS";}' \
        '{"enabled" = 0; "name" = "MESSAGES";}' \
        '{"enabled" = 0; "name" = "CONTACT";}' \
        '{"enabled" = 0; "name" = "EVENT_TODO";}' \
        '{"enabled" = 0; "name" = "IMAGES";}' \
        '{"enabled" = 0; "name" = "BOOKMARKS";}' \
        '{"enabled" = 0; "name" = "MUSIC";}' \
        '{"enabled" = 0; "name" = "MOVIES";}' \
        '{"enabled" = 0; "name" = "PRESENTATIONS";}' \
        '{"enabled" = 0; "name" = "SPREADSHEETS";}' \
        '{"enabled" = 0; "name" = "SOURCE";}' \
        '{"enabled" = 0; "name" = "MENU_OTHER";}' \
        '{"enabled" = 0; "name" = "MENU_CONVERSION";}' \
        '{"enabled" = 0; "name" = "MENU_EXPRESSION";}' \
        '{"enabled" = 0; "name" = "MENU_WEBSEARCH";}' \
        '{"enabled" = 0; "name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'
    defaults write com.apple.spotlight showSpotlightSuggestions -bool false
    defaults write com.apple.spotlight showQuerySuggestions -bool false
    defaults write com.apple.lookup.shared LookupSuggestionsDisabled -bool true
    defaults write com.apple.Siri SuggestionsSpotlightEnabled -bool false
    execute_sudo killall mds >/dev/null 2>&1 || true
}

# Spotlight now only indexes Applications and will not surface online suggestions.
if [ "$DRY_RUN" = true ]; then
    print_dry_run "Enable Spotlight for Applications only"
    print_dry_run "Disable Spotlight web and Siri suggestions"
    print_dry_run "Restart Spotlight services"
    check_status "Spotlight configured"
    exit 0
fi

run_spotlight_configuration
check_status "Spotlight configured"
