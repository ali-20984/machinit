#!/bin/bash
#
# Script: 022_install_codex.sh
# Description: Install Codex
# Author: supermarsx
#
source "$(dirname "$0")/utils.sh"

print_install "OpenAI Codex CLI"
install_brew_package codex "--cask"
