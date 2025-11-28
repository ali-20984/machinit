#!/bin/bash
echo "Setting up basic environment variables..."

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Example: export PATH or other setup
echo "Environment setup complete."
