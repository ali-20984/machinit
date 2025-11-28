#!/bin/bash
#
# Script: 004_install_nvm.sh
# Description: Install Nvm
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

echo "Installing nvm..."
install_brew_package nvm

# Create nvm directory
mkdir -p ~/.nvm

# Fix permissions for nvm directory
chmod -R 755 ~/.nvm

# Get nvm prefix
NVM_PREFIX=$(brew --prefix nvm)

# Add nvm configuration to shell profile (zshrc and bash_profile)
for profile in "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.bashrc"; do
    # Create file if it doesn't exist
    touch "$profile"
    
    if ! grep -q "nvm.sh" "$profile"; then
        echo "Adding nvm to $profile..."
        echo "" >> "$profile"
        echo '# NVM configuration' >> "$profile"
        echo 'export NVM_DIR="$HOME/.nvm"' >> "$profile"
        echo "[ -s \"$NVM_PREFIX/nvm.sh\" ] && \. \"$NVM_PREFIX/nvm.sh\"  # This loads nvm" >> "$profile"
        echo "[ -s \"$NVM_PREFIX/etc/bash_completion.d/nvm\" ] && \. \"$NVM_PREFIX/etc/bash_completion.d/nvm\"  # This loads nvm bash_completion" >> "$profile"
    else
        echo "nvm already configured in $profile"
    fi
done

echo "nvm installed and configured."
