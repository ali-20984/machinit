#!/bin/bash
echo "Installing comprehensive development tools..."

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

echo "Development tools installation complete."
