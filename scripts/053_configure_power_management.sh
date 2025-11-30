#!/bin/bash
#
# Script: 053_configure_power_management.sh
# Description: Configure Power Management
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Configuring Power Management..."

# Enable lid wakeup
echo "Enabling lid wakeup..."
execute_sudo pmset -a lidwake 1

# Sleep the display after 15 minutes
echo "Setting display sleep to 15 minutes..."
execute_sudo pmset -a displaysleep 15

# Disable machine sleep while charging
echo "Disabling machine sleep while charging..."
execute_sudo pmset -c sleep 0

# Enable Low Power Mode (Always)
echo "Enabling Low Power Mode (Always)..."
execute_sudo pmset -a lowpowermode 1

echo "Power management configuration complete."
