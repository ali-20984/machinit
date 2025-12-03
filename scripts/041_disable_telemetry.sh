#!/bin/bash
#
# Script: 041_disable_telemetry.sh
# Description: Disable Telemetry
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_info "Disabling macOS telemetry and analytics..."

CURRENT_UID=$(id -u)

function disable_launch_item() {
    local scope="$1"
    local plist="$2"
    local description="$3"
    local target

    if [ "$scope" = "gui" ]; then
        target="gui/$CURRENT_UID"
    else
        target="system"
    fi

    if execute_sudo launchctl bootout "$target" "$plist"; then
        print_success "$description disabled via launchctl bootout."
        return 0
    fi

    print_info "bootout failed for $description. Trying legacy unload..."
    if execute_sudo launchctl unload -w "$plist"; then
        print_success "$description disabled via legacy unload."
    else
        print_error "Failed to disable $description."
    fi
}

# Disable Crash Reporter dialogs and crash submissions
set_default com.apple.CrashReporter DialogType string none
set_default com.apple.SubmitDiagInfo AutoSubmit bool false
set_default com.apple.SubmitDiagInfo SubmitDiagInfo bool false

# Disable personalized advertising and limit tracking
set_default com.apple.AdLib allowApplePersonalizedAdvertising bool false
set_default com.apple.AdLib forceLimitAdTracking bool true

# Disable Siri analytics (limit data sharing)
set_default com.apple.assistant.support "Siri Data Sharing Opt-In Status" int 2

# Unload Crash Reporter
print_info "Unloading Crash Reporter launch services..."
disable_launch_item gui /System/Library/LaunchAgents/com.apple.ReportCrash.plist "ReportCrash agent"
disable_launch_item system /System/Library/LaunchDaemons/com.apple.ReportCrash.Root.plist "ReportCrash daemon"

print_success "Telemetry disabled."
