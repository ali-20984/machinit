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
if [ "$YES" = false ]; then
    read -p "Proceed? [y/N] " answer
    if [[ ! "$answer" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Aborting — no applications were restarted."
        exit 0
    fi
else
    echo "--yes detected: proceeding non-interactively."
fi

for app in "${apps[@]}"; do
    echo "Restarting: $app"
    killall "$app" &>/dev/null || true
done

echo "Restart complete. Some changes might still need a logout/restart to fully apply."

# Flush cfprefsd cache and restart Dock so dockutil changes are picked up
# Ensure these run as the original (non-root) user so the right session is affected
echo "Flushing preference cache and restarting Dock for user $ORIGINAL_USER..."
execute_as_user killall cfprefsd &>/dev/null || true
execute_as_user killall Dock &>/dev/null || true
