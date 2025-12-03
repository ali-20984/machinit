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

The script executes a series of ordered scripts located in the `scripts/` directory.

### Scripts Reference

| Script | Description |
|--------|-------------|
| `001_env_setup.sh` | Env Setup |
| `002_install_homebrew.sh` | Install Homebrew |
| `003_update_terminal_tools.sh` | Update Terminal Tools |
| `004_install_nvm.sh` | Install Nvm |
| `005_install_rust.sh` | Install Rust |
| `006_install_vcpkg.sh` | Install Vcpkg |
| `007_install_powershell.sh` | Install Powershell |
| `008_install_cli_tools.sh` | Install Cli Tools |
| `009_install_fonts.sh` | Install Fonts |
| `010_install_apps.sh` | Install Apps |
| `011_install_dotfiles.sh` | Install Dotfiles |
| `020_configure_firefox_policies.sh` | Configure Firefox Policies |
| `020_install_firefox.sh` | Install Firefox |
| `021_install_vscode.sh` | Install Vscode |
| `022_install_codex.sh` | Install Codex |
| `023_install_opencode.sh` | Install Opencode |
| `024_install_beeper.sh` | Install Beeper |
| `025_install_github_desktop.sh` | Install Github Desktop |
| `026_install_keepassxc.sh` | Install Keepassxc |
| `027_install_chrome_devtools_mcp.sh` | Install Chrome Devtools Mcp |
| `028_install_google_chrome.sh` | Install Google Chrome |
| `029_install_nextcloud.sh` | Install Nextcloud |
| `030_install_bitwarden.sh` | Install Bitwarden |
| `031_install_vscode_extensions.sh` | Install Vscode Extensions |
| `032_install_microsoft_excel.sh` | Install Microsoft Excel |
| `033_install_microsoft_outlook.sh` | Install Microsoft Outlook |
| `034_install_microsoft_powerpoint.sh` | Install Microsoft Powerpoint |
| `035_install_microsoft_word.sh` | Install Microsoft Word |
| `036_install_adobe_reader.sh` | Install Adobe Reader |
| `037_install_openvpn.sh` | Install Openvpn |
| `041_disable_telemetry.sh` | Disable Telemetry |
| `042_disable_siri.sh` | Disable Siri |
| `043_configure_dock_and_mission_control.sh` | Configure Dock And Mission Control |
| `044_configure_dock_apps.sh` | Configure Dock Apps |
| `045_configure_safari.sh` | Configure Safari |
| `046_configure_terminal.sh` | Configure Terminal |
| `047_configure_login_screen.sh` | Configure Login Screen |
| `050_performance_optimizations.sh` | Performance Optimizations |
| `051_configure_system_ui_ux.sh` | Configure System Ui Ux |
| `052_configure_finder_and_sidebar.sh` | Configure Finder And Sidebar |
| `053_configure_power_management.sh` | Configure Power Management |
| `054_configure_input_devices.sh` | Configure Input Devices |
| `055_configure_security_privacy.sh` | Configure Security Privacy |
| `056_configure_system_apps.sh` | Configure System Apps |
| `099_set_wallpaper.sh` | Set Wallpaper |
| `999_cleanup.sh` | Cleanup |

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

### Advanced UI helpers

There are a couple of utilities and workflow improvements to make per-user UI changes safer and easier:

- `scripts/999_restart_apps.sh` — Final, single-shot restart script that safely restarts UI services (Dock, Finder, cfprefsd, SystemUIServer, etc.) for the original user. It supports a non-interactive mode via `--yes` / `-y`.

- `set_user_default` — A new helper in `scripts/utils.sh` which wraps `defaults write` and ensures per-user preferences are written as the original user (not root). Scripts that modify Finder, Dock and other per-user settings use this helper to avoid silently writing root preferences.

These two changes are designed to avoid race conditions and permission problems when the installer is invoked with `sudo`.

### Terminal Theme: Shades of Fire (configurable)

Terminal theming is now configurable via `config.toml` under the `[appearance]` section. The default value is `shades_of_fire`, which applies the warm, ember palette to Terminal.app and adds a matching prompt block to `~/.zshrc`.

Additionally, a minimal iTerm2 theme-import script and two small color presets are included under `assets/themes/` (`shades_of_fire.itermcolors` and `charcoal.itermcolors`). The installer `scripts/046_configure_iterm2.sh` will open the chosen `.itermcolors` file (or dry-run) and allow iTerm2 to register the preset when iTerm2 is installed.

The prompt block looks like:

```text
# Shades of Fire prompt (user/folder in warm ember tones)
# Username: bright orange; arrow: red; current dir: warm yellow
export PROMPT='%F{202}%n%f %F{196}➜%f %F{220}%~%f '
```


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
| `ll` | robust wrapper (prefers GNU ls from Homebrew/gls, falls back to system ls) | Enhanced list view |
| `reloaddns` | `dscacheutil -flushcache ...` | Flush DNS cache |
| `dnsreload` | `dscacheutil -flushcache ...` | Flush DNS cache (alias) |
| `jsrefresh` | `rm -rf node_modules ...` | Reinstall npm dependencies |
| `..` | `cd ..` | Go up one directory |
| `c` | `clear` | Clear terminal |
| `o` | `open .` | Open current directory in Finder |
| `zshconf` | `nano ~/.zshrc` | Edit zsh config quickly |
| `myip` | `curl ifconfig.me` | Show public IP |
| `localip` | `ipconfig getifaddr en0` | Show local IP |
| `afk` | `pmset displaysleepnow` | Lock screen (display sleep) |
| `wifi_pass` | `security find-generic-password -wa` | Show WiFi password |
| `projects` | `cd ~/Projects` | Jump to your Projects folder |
| `repos` | `cd ~/Projects` | Same as `projects` (recommended location: `~/Projects` which may be symlinked to `~/Documents/Projects`) |
| `qfind` | `find . -name` | Quick find alias |

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

Additional useful utilities added to `~/.functions`:

- `findPid` — find PID(s) for a matching process name or regex (uses `lsof -t -c`).
- `lsock` — alias to `sudo lsof -i -P` for inspecting listening sockets.

- `recent` — function to cd into the most recently-modified project under `~/Projects` (useful shortcut when frequently switching between projects).

## 🧪 Development

### Linting

To check the scripts for syntax errors and best practices:

```bash
./dev_scripts/lint.sh
```

### CI/CD

This project uses GitHub Actions for Continuous Integration. The pipeline runs `shellcheck` on all scripts and executes a dry-run test on macOS runners to ensure stability.

#### New UI/flags CI checks

I added a new lightweight CI test to validate UI helper scripts and flags without making system changes:

- `tests/test_ui_flags.sh` — non-destructive checks (runs in `DRY_RUN`) which:
    - Confirm `set_user_default` helper exists,
    - Validate `scripts/999_restart_apps.sh` accepts `--yes`/`-y` in non-interactive mode,
    - Verify `install.sh` supports `--run-only <N>` and `--restart-ui` signalling,
    - Ensure `scripts/052_configure_finder_and_sidebar.sh` includes verification code and uses `set_user_default`.

Run the test locally:
```bash
chmod +x tests/test_ui_flags.sh
./tests/test_ui_flags.sh
```

There are additional non-destructive tests for logging and resume behavior:

```bash
chmod +x tests/test_resume_and_logs.sh
./tests/test_resume_and_logs.sh
```

### Logs & resume

- The installer now writes logs to `./logs/` by default (created per run). Logs are automatically ignored in `.gitignore`.
- New CLI flags:
    - `--clear-logs` — remove the logs directory and exit.
    - `--resume-failure` — resume from the last failed script recorded in `logs/last_failed`.
    - `--exit` — exit immediately without running scripts (useful for scripting and CI).

These make CI-friendly workflows easier and help recover from intermittent failures.

## ⚠️ Disclaimer

This script modifies system settings, installs software, and changes configuration files.

- **Review the scripts** in the `scripts/` directory before running.
- **Backup your data** if running on a machine with important files.
- The performance optimizations (especially disabling Spotlight and hibernation) are aggressive.

## 📄 License

[MIT](LICENSE.md)
