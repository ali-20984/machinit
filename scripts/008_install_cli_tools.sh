#!/bin/bash
echo "Installing comprehensive development tools..."

# General Utilities
echo "Installing Coreutils..."
brew install coreutils

echo "Installing Moreutils..."
brew install moreutils

echo "Installing Findutils..."
brew install findutils

echo "Installing GNU Sed..."
brew install gnu-sed --with-default-names

echo "Installing Bash and Completion..."
brew install bash
brew install bash-completion2

echo "Installing Tree..."
brew install tree

echo "Installing p7zip..."
brew install p7zip

echo "Installing Lua..."
brew install lua

echo "Installing GitHub CLI..."
brew install gh

# Network Tools
echo "Installing Network Tools..."
brew install iproute2mac bind mtr

# Version Control
echo "Installing/Updating Git..."
brew install git

# C++ Development Tools
echo "Installing C++ tools..."
# cmake: Build system
# ninja: Build system (often faster than make)
# llvm: Compiler infrastructure (includes clang tools)
# gcc: GNU Compiler Collection
# pkg-config: Helper to insert correct compiler options
# autoconf/automake/libtool: Build system tools
brew install cmake ninja llvm gcc pkg-config autoconf automake libtool

# Python Development Tools
echo "Installing Python tools..."
# pyenv: Python version management
# pyenv-virtualenv: Plugin for pyenv to manage virtualenvs
# poetry: Dependency management and packaging
brew install pyenv pyenv-virtualenv poetry

# JavaScript/Node Development Tools
echo "Installing JavaScript/Node tools..."
# yarn: Package manager
# pnpm: Fast, disk space efficient package manager
# Note: These might install a system node version as a dependency.
# You can still use nvm (installed in 004) to manage active node versions.
brew install yarn pnpm

echo "Cleaning up Brew..."
brew cleanup

echo "Development tools installation complete."
