#!/bin/bash
#
# Script: 042_disable_siri.sh
# Description: Disable Siri
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_info "Fully disabling Siri..."

set_default com.apple.assistant.support "Assistant Enabled" bool false
set_default com.apple.Siri StatusMenuVisible bool false
set_default com.apple.Siri UserHasDeclinedEnable bool true

if [ "$DRY_RUN" = true ]; then
    print_dry_run "killall SystemUIServer"
    print_dry_run "killall Siri"
else
    execute_as_user killall SystemUIServer 2>/dev/null || true
    execute_as_user killall Siri 2>/dev/null || true
fi

print_success "Siri has been disabled."
