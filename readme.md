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

### Dry Run Mode

To see what changes would be made without actually applying them, use the `--dry-run` flag:

```bash
./install.sh --dry-run
```

### Configuration

You can customize the installation process by editing `config.toml`. This file allows you to define:
- System defaults (Computer Name, Timezone)
- Applications to install (Homebrew Formulae and Casks)
- macOS Defaults (Dock settings, UI tweaks)

## 🛠️ What it Does

The script executes a series of ordered scripts located in the `scripts/` directory:

### System & Environment

- **Homebrew**: Installs Homebrew and updates packages.
- **Shell**: Installs PowerShell, updates terminal tools (coreutils), and configures `nvm` (Node.js) and `pyenv` (Python).
- **Fonts**: Installs custom fonts (Fantasque Sans Mono).
- **Telemetry**: Disables macOS telemetry, crash reporting, and personalized ads.
- **Privacy**: Disables Siri, hides iCloud Drive, enables Firewall and Stealth Mode.

### Applications

- **Browsers**: Firefox (with extensions), Google Chrome.
- **Development**: VS Code (with extensions), Codex, OpenCode, Chrome DevTools MCP, iTerm2, Mark Text, Standard Notes.
- **Communication**: Beeper, Outlook.
- **Productivity**: Microsoft Office 365 (Word, Excel, PowerPoint), Adobe Acrobat Reader, Nextcloud, Bitwarden, KeePassXC.
- **Utilities**: GitHub Desktop, OpenVPN Connect, vcpkg, Glances, pgcli.

### Development Stack

- **Languages**: Rust, Node.js, Python, C++ (gcc, llvm, cmake, ninja).
- **Tools**: Git, Yarn, pnpm, Poetry, jq, httpie, ripgrep, fd, fzf.

### Customization & UI

- **Wallpaper**: Sets a custom wallpaper centered on a black background.
- **Dock**: Configures Dock size, removes default apps, and pins selected apps.
- **Terminal**: Sets a custom "Matrix Red" theme for Terminal.app.
- **Login Screen**: Configures a "Console-style" login screen.
- **Safari**: Clears favorites, history, and suppresses "launched" notifications.
- **Dotfiles**: Installs `.aliases`, `.functions`, `.nanorc`, and `.gitignore_global`.

### Performance Optimizations

- **Spotlight**: Disables indexing for better performance.
- **Animations**: Reduces motion, transparency, and disables window animations.
- **SSD**: Optimizes power management for SSDs (disables hibernation, sleepimage).
- **HiDPI**: Enables HiDPI display modes.
- **Power Management**: Enables Low Power Mode (Always) and disables sleep while charging.

### Included Shell Enhancements

The installation includes a set of useful aliases and functions (installed to `~/.aliases` and `~/.functions`).

#### Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `bup` | `brew update && brew upgrade && brew cleanup` | Update Homebrew and cleanup |
| `shrug` | `echo '¯\_(ツ)_/¯' \| pbcopy` | Copy shrug kaomoji to clipboard |
| `ll` | `ls -AhlFo ...` | Enhanced list view |
| `reloaddns` | `dscacheutil -flushcache ...` | Flush DNS cache |
| `dnsreload` | `dscacheutil -flushcache ...` | Flush DNS cache (alias) |
| `jsrefresh` | `rm -rf node_modules ...` | Reinstall npm dependencies |
| `..` | `cd ..` | Go up one directory |
| `c` | `clear` | Clear terminal |
| `o` | `open .` | Open current directory in Finder |
| `myip` | `curl ifconfig.me` | Show public IP |
| `localip` | `ipconfig getifaddr en0` | Show local IP |
| `afk` | `pmset displaysleepnow` | Lock screen (display sleep) |
| `wifi_pass` | `security find-generic-password -wa` | Show WiFi password |

#### Functions

- **`mkd <dir>`**: Create a directory and enter it.
- **`cdf`**: Change directory to the current Finder window.
- **`targz <file>`**: Create a `.tar.gz` archive using the best available compression.
- **`fs [path]`**: Determine size of a file or directory.
- **`server [port]`**: Start a simple HTTP server (default port 8000).
- **`dataurl <file>`**: Create a data URL from a file.
- **`digga <domain>`**: Run `dig` and display useful info.
- **`tre [path]`**: Enhanced `tree` command.
- **`generate_git_key <email>`**: Generate a new SSH key for GitHub and add it to the agent.

## 🧪 Development

### Linting

To check the scripts for syntax errors and best practices:

```bash
./dev_scripts/lint.sh
```

### CI/CD

This project uses GitHub Actions for Continuous Integration. The pipeline runs `shellcheck` on all scripts and executes a dry-run test on macOS runners to ensure stability.

## ⚠️ Disclaimer

This script modifies system settings, installs software, and changes configuration files.

- **Review the scripts** in the `scripts/` directory before running.
- **Backup your data** if running on a machine with important files.
- The performance optimizations (especially disabling Spotlight and hibernation) are aggressive.

## 📄 License

[MIT](LICENSE.md)
