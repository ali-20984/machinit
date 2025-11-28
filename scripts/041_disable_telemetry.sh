#!/bin/bash
#
# Script: 041_disable_telemetry.sh
# Description: Disable Telemetry
# Author: supermarsx
#
echo "Disabling macOS telemetry and analytics..."

# Disable Crash Reporter
defaults write com.apple.CrashReporter DialogType -string "none"

# Disable sending crash reports to Apple
defaults write com.apple.SubmitDiagInfo AutoSubmit -bool false

# Disable sending usage data to Apple
defaults write com.apple.SubmitDiagInfo SubmitDiagInfo -bool false

# Disable personalized advertising
defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false
defaults write com.apple.AdLib forceLimitAdTracking -bool true

# Disable Siri analytics (if Siri is enabled, this limits data collection)
defaults write com.apple.assistant.support "Siri Data Sharing Opt-In Status" -int 2

# Unload Crash Reporter
echo "Unloading Crash Reporter..."
launchctl unload -w /System/Library/LaunchAgents/com.apple.ReportCrash.plist
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.ReportCrash.Root.plist

echo "Telemetry disabled."
