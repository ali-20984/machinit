#!/bin/bash
#
# Script: 044_configure_dock_apps.sh
# Description: Configure Dock Apps
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Configuring Dock apps..."

echo "Ensuring dockutil is installed..."
install_brew_package dockutil

if ! command -v dockutil &>/dev/null; then
	print_error "dockutil not found even after attempted installation. Skipping Dock configuration."
	exit 0
fi

echo "Clearing existing Dock items..."
execute dockutil --remove all --no-restart

echo "Adding apps to Dock..."
declare -a DOCK_APPS=(
	"/Applications/Visual Studio Code.app|Visual Studio Code"
	"/Applications/Firefox.app|Firefox"
	"/System/Applications/Utilities/Terminal.app|Terminal"
	"/Applications/Beeper.app|Beeper"
	"/Applications/Bitwarden.app|Bitwarden"
	"/Applications/GitHub Desktop.app|GitHub Desktop"
	"/Applications/Microsoft Word.app|Microsoft Word"
	"/Applications/Microsoft Excel.app|Microsoft Excel"
)

for entry in "${DOCK_APPS[@]}"; do
	IFS='|' read -r app_path label <<<"$entry"
	if [ ! -e "$app_path" ]; then
		print_info "Skipping $label because $app_path was not found."
		continue
	fi

	if execute dockutil --add "$app_path" --no-restart; then
		print_success "Pinned $label to the Dock."
	else
		print_error "Failed to pin $label. Run 'dockutil --add \"$app_path\"' manually if needed."
	fi
done

# Restart Dock to apply changes
execute killall Dock

echo "Dock apps configured."
