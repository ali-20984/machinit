#!/bin/bash
source "$(dirname "$0")/utils.sh"

echo "Installing applications..."

echo "Installing iTerm2..."
install_brew_package iterm2

echo "Installing Mark Text..."
install_brew_package mark-text "--cask"

echo "Installing Standard Notes..."
install_brew_package standard-notes "--cask"

echo "Applications installed."
