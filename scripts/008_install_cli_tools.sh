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

#!/bin/bash
source "$(dirname "$0")/utils.sh"

echo "Installing comprehensive development tools..."

# General Utilities
echo "Installing Coreutils..."
install_brew_package coreutils

echo "Installing Moreutils..."
install_brew_package moreutils

echo "Installing Findutils..."
install_brew_package findutils

echo "Installing GNU Sed..."
install_brew_package gnu-sed "--with-default-names"

echo "Installing Bash and Completion..."
install_brew_package bash
install_brew_package bash-completion2

echo "Installing Tree..."
install_brew_package tree

echo "Installing p7zip..."
install_brew_package p7zip

echo "Installing Pigz (Parallel Gzip)..."
install_brew_package pigz

echo "Installing Zopfli..."
install_brew_package zopfli

echo "Installing Lua..."
install_brew_package lua

echo "Installing GitHub CLI..."
install_brew_package gh

# Network Tools
echo "Installing Network Tools..."
install_brew_package iproute2mac
install_brew_package bind
install_brew_package mtr
install_brew_package nmap

# Version Control
echo "Installing/Updating Git..."
install_brew_package git

# C++ Development Tools
echo "Installing C++ tools..."
install_brew_package cmake
install_brew_package ninja
install_brew_package llvm
install_brew_package gcc
install_brew_package pkg-config
install_brew_package autoconf
install_brew_package automake
install_brew_package libtool

# Python Development Tools
echo "Installing Python tools..."
install_brew_package pyenv
install_brew_package pyenv-virtualenv
install_brew_package poetry

# JavaScript/Node Development Tools
echo "Installing JavaScript/Node tools..."
install_brew_package yarn
install_brew_package pnpm

echo "Cleaning up Brew..."
brew cleanup

echo "Development tools installation complete."

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
