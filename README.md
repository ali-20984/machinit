# MachInit: Hands-off Mac Initialization

MachInit is an automated, "hands-off" initialization script for macOS. It sets up a fresh Mac with a curated list of applications, development tools, system preferences, and customizations in a sequential, migration-style manner.

## 🚀 Getting Started

### Prerequisites

- A fresh installation of macOS (recommended, but works on existing setups too).
- An active internet connection.
- Administrator privileges (you will be prompted for `sudo` password).

### Installation

1. Clone this repository:

    ```bash
    git clone https://github.com/supermarsx/machinit.git
    cd machinit
    ```

2. Make the installer executable and run it:

    ```bash
    chmod +x install.sh
    ./install.sh
    ```

## 🛠️ What it Does

The script executes a series of ordered scripts located in the `scripts/` directory:

### System & Environment

- **Homebrew**: Installs Homebrew and updates packages.
- **Shell**: Installs PowerShell, updates terminal tools (coreutils), and configures `nvm` (Node.js) and `pyenv` (Python).
- **Fonts**: Installs custom fonts (Fantasque Sans Mono).
- **Telemetry**: Disables macOS telemetry, crash reporting, and personalized ads.
- **Privacy**: Disables Siri and hides iCloud Drive.

### Applications

- **Browsers**: Firefox (with extensions), Google Chrome.
- **Development**: VS Code (with extensions), Codex, OpenCode, Chrome DevTools MCP, iTerm2.
- **Communication**: Beeper, Outlook.
- **Productivity**: Microsoft Office 365 (Word, Excel, PowerPoint), Adobe Acrobat Reader, Nextcloud, Bitwarden, KeePassXC.
- **Utilities**: GitHub Desktop, OpenVPN Connect, vcpkg.

### Development Stack

- **Languages**: Rust, Node.js, Python, C++ (gcc, llvm, cmake, ninja).
- **Tools**: Git, Yarn, pnpm, Poetry.

### Customization & UI

- **Wallpaper**: Sets a custom wallpaper centered on a black background.
- **Dock**: Configures Dock size, removes default apps, and pins selected apps.
- **Terminal**: Sets a custom "Matrix Red" theme for Terminal.app.
- **Login Screen**: Configures a "Console-style" login screen.
- **Safari**: Clears favorites and suppresses "launched" notifications.

### Performance Optimizations

- **Spotlight**: Disables indexing for better performance.
- **Animations**: Reduces motion, transparency, and disables window animations.
- **SSD**: Optimizes power management for SSDs (disables hibernation, sleepimage).
- **HiDPI**: Enables HiDPI display modes.

## ⚠️ Disclaimer

This script modifies system settings, installs software, and changes configuration files.

- **Review the scripts** in the `scripts/` directory before running.
- **Backup your data** if running on a machine with important files.
- The performance optimizations (especially disabling Spotlight and hibernation) are aggressive.

## 📄 License

[MIT](LICENSE.md)
