#!/bin/bash
#
# Script: 044_configure_dock_apps.sh
# Description: Configure Dock Apps
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_config "Dock Apps"

echo "Ensuring dockutil is installed..."
install_brew_package dockutil

if ! command -v dockutil &>/dev/null; then
    print_error "dockutil not found even after attempted installation. Skipping Dock configuration."
    exit 0
fi

# Function: find_app
# Description: Find an app by name pattern in common locations
find_app() {
    local pattern="$1"
    local app_path=""

    # Search in common system locations plus the original user's ~/Applications
    # (some users install apps into their home Applications folder)
    local search_paths=(/Applications /System/Applications /System/Applications/Utilities "${ORIGINAL_HOME}/Applications")

    # Use a loop so we can gracefully handle missing dirs and limit the number
    # of results so head -1 is predictable.
    for p in "${search_paths[@]}"; do
        if [ -d "$p" ]; then
            app_path=$(find "$p" -maxdepth 2 -name "*.app" 2>/dev/null | grep -i "$pattern" | head -1 || true)
            if [ -n "$app_path" ]; then
                echo "$app_path"
                return 0
            fi
        fi
    done

    # Nothing found
    echo ""
}

# By default we remove existing Dock items before pinning the curated list
# To keep existing pinned apps, set SKIP_DOCK_CLEANUP=1 in the environment
if [ -z "${SKIP_DOCK_CLEANUP:-}" ] || [ "${SKIP_DOCK_CLEANUP}" = "0" ]; then
    echo "Clearing existing Dock items..."
    # dockutil must run as the non-root user so we modify the correct user's Dock.
    execute_as_user dockutil --remove all --no-restart
else
    echo "SKIP_DOCK_CLEANUP is set; skipping removal of existing Dock items.";
fi

echo "Adding apps to Dock..."

# Define apps to add: "search pattern|display name"
declare -a DOCK_APPS=(
    "Visual Studio Code|Visual Studio Code"
    "Firefox|Firefox"
    "Terminal.app|Terminal"
    "Beeper|Beeper"
    "Bitwarden|Bitwarden"
    "GitHub Desktop|GitHub Desktop"
    "Microsoft Word|Microsoft Word"
    "Microsoft Excel|Microsoft Excel"
)

for entry in "${DOCK_APPS[@]}"; do
    IFS='|' read -r pattern label <<<"$entry"

    app_path=$(find_app "$pattern")

    if [ -z "$app_path" ] || [ ! -e "$app_path" ]; then
        print_skip "Skipping $label (not found)"
        continue
    fi

    # Ensure dockutil commands run in the original user's context so they apply
    # to the correct Dock (install.sh may run as root with sudo).
    if execute_as_user dockutil --add "$app_path" --no-restart; then
        print_success "Pinned $label to the Dock."
    else
        print_error "Failed to pin $label."
    fi
done

# Verify preference was written and flush cfprefsd cache so the Dock picks up
# the changes reliably when it next starts. cfprefsd caches preferences in
# memory and can prevent the Dock reading the updated file until it is
# restarted or the cache is flushed for the user session.
print_info "Verifying Dock preferences and flushing cfprefsd for user $ORIGINAL_USER..."
execute_as_user defaults read com.apple.dock persistent-apps >/dev/null 2>&1 || true
execute_as_user killall cfprefsd &>/dev/null || true

# Restarting UI components is deferred until the end of the full installer
# We use --no-restart above so changes are collected and can be applied once
# at the very end (see scripts/999_restart_apps.sh)

echo "Dock apps configured."

# Add a separate Dock "folders" section for quick access to Downloads and Projects.
echo "Adding folders (Downloads, Projects) to Dock..."

# Ensure Downloads exists for the original user
download_folder="${ORIGINAL_HOME}/Downloads"
projects_folder="${ORIGINAL_HOME}/Projects"

if [ ! -d "$download_folder" ]; then
    execute_as_user mkdir -p "$download_folder"
    print_info "Created missing Downloads folder at $download_folder"
fi

# Ensure Projects location exists (the installer may create a Documents/Projects earlier)
if [ -d "${ORIGINAL_HOME}/Documents/Projects" ]; then
    # Prefer the canonical Documents/Projects folder when it exists so
    # we pin the real directory (not a symlink) to the Dock.
    projects_folder="${ORIGINAL_HOME}/Documents/Projects"
else
    if [ -d "${ORIGINAL_HOME}/Projects" ]; then
        # If Projects exists and is a symlink, try to resolve it to the
        # real path so we avoid pinning the symlink itself.
        if [ -L "${ORIGINAL_HOME}/Projects" ]; then
            if command -v python3 >/dev/null 2>&1; then
                resolved=$(python3 -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' "${ORIGINAL_HOME}/Projects")
                if [ -d "$resolved" ]; then
                    projects_folder="$resolved"
                else
                    projects_folder="${ORIGINAL_HOME}/Projects"
                fi
            elif command -v realpath >/dev/null 2>&1; then
                projects_folder=$(realpath "${ORIGINAL_HOME}/Projects")
            elif command -v readlink >/dev/null 2>&1; then
                target=$(readlink "${ORIGINAL_HOME}/Projects")
                if [ -n "$target" ]; then
                    if [[ "$target" != /* ]]; then
                        # create an absolute path from relative target
                        projects_folder="${ORIGINAL_HOME}/$(dirname "${ORIGINAL_HOME}/Projects")/$target"
                    else
                        projects_folder="$target"
                    fi
                else
                    projects_folder="${ORIGINAL_HOME}/Projects"
                fi
            else
                projects_folder="${ORIGINAL_HOME}/Projects"
            fi
        else
            projects_folder="${ORIGINAL_HOME}/Projects"
        fi
    else
        execute_as_user mkdir -p "${ORIGINAL_HOME}/Projects"
        print_info "Created missing Projects folder at ${ORIGINAL_HOME}/Projects"
        projects_folder="${ORIGINAL_HOME}/Projects"
    fi
fi

# Add folders to Dock as stacks (right-side section). dockutil will place folders
# on the right-hand (others) side by default. Use a friendly label and grid view.
if execute_as_user dockutil --add "$download_folder" --label Downloads --view grid --display stack --no-restart; then
    print_success "Pinned Downloads folder to Dock (as a stack)."
else
    print_error "Failed to pin Downloads folder to Dock."
fi

if execute_as_user dockutil --add "$projects_folder" --label Projects --view grid --display stack --no-restart; then
    print_success "Pinned Projects folder to Dock (as a stack)."
else
    print_error "Failed to pin Projects folder to Dock."
fi
