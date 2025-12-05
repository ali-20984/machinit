#!/bin/bash
#
# Script: 999_restart_apps.sh
# Description: Restart UI / Dock / Finder and other apps at the end of the full installer
# Author: supermarsx (automated change)
#
source "$(dirname "$0")/utils.sh"

# Default: require confirmation. Set YES=true when --yes or -y is passed.
YES=false
if [ "$1" = "--yes" ] || [ "$1" = "-y" ]; then
    YES=true
fi

print_config "Final: Restart UI / Dock / Finder & related apps"

echo "This script restarts a small list of UI processes so changes made by the
other config scripts take effect. Terminal is intentionally excluded so you
can run this safely at the end of a full run."

apps=(
    "Activity Monitor"
    "Address Book"
    "Calendar"
    "cfprefsd"
    "Contacts"
    "Dock"
    "Finder"
    "Google Chrome Canary"
    "Google Chrome"
    "Mail"
    "Messages"
    "Opera"
    "Photos"
    "Safari"
    "SizeUp"
    "Spectacle"
    "SystemUIServer"
    "Transmission"
    "Tweetbot"
    "Twitter"
    "iCal"
)

echo "About to restart the following UI processes: ${apps[*]}"
if [ "${DRY_RUN:-false}" = "true" ]; then
    echo "DRY RUN enabled — no applications will be restarted."
    # In a dry-run don't prompt for confirmation — behave non-interactively so
    # automated tests and CI won't hang waiting for user input.
    YES=true
fi
if [ "$YES" = false ]; then
    # Use -r to avoid backslash interpretation (ShellCheck SC2162)
    read -r -p "Proceed? [y/N] " answer
    if [[ ! "$answer" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Aborting — no applications were restarted."
        exit 0
    fi
else
    echo "--yes detected: proceeding non-interactively."
fi

if [ "${DRY_RUN:-false}" = "true" ]; then
    for app in "${apps[@]}"; do
        echo "[DRY RUN] would restart: $app"
    done
else
    for app in "${apps[@]}"; do
        echo "Restarting: $app"
        execute_as_user killall "$app" &>/dev/null || true
    done
fi

echo "Restart complete. Some changes might still need a logout/restart to fully apply."

# Flush cfprefsd cache and restart Dock so dockutil changes are picked up
# Ensure these run as the original (non-root) user so the right session is affected
echo "Flushing preference cache and restarting Dock for user $ORIGINAL_USER..."
if [ "${DRY_RUN:-false}" = "true" ]; then
    echo "[DRY RUN] would flush cfprefsd and restart Dock for user $ORIGINAL_USER"
else
    execute_as_user killall cfprefsd &>/dev/null || true
    execute_as_user killall Dock &>/dev/null || true
fi
