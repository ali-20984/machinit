#!/bin/bash
echo "Updating Homebrew..."
brew update

echo "Upgrading installed Homebrew packages..."
brew upgrade

echo "Cleaning up..."
brew cleanup

echo "Terminal tools updated."
