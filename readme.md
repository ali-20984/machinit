![machinit banner](https://github.com/user-attachments/assets/4126f9e7-dc86-4024-b7c0-9ae04b3aeba5)

<br>
<br>

[![CI](https://img.shields.io/github/actions/workflow/status/supermarsx/machinit/.github/workflows/test-suite.yml?branch=main&style=flat-square)](https://github.com/supermarsx/machinit/actions/workflows/test-suite.yml)
[![GitHub stars](https://img.shields.io/github/stars/supermarsx/machinit?style=flat-square)](https://github.com/supermarsx/machinit/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/supermarsx/machinit?style=flat-square)](https://github.com/supermarsx/machinit/network/members)
[![GitHub watchers](https://img.shields.io/github/watchers/supermarsx/machinit?style=flat-square)](https://github.com/supermarsx/machinit/watchers)
[![Open issues](https://img.shields.io/github/issues/supermarsx/machinit?style=flat-square)](https://github.com/supermarsx/machinit/issues)
[![Made with Shell & Tears](https://img.shields.io/badge/made%20with-Shell%20%26%20Tears-ffa500?style=flat-square)](https://github.com/supermarsx/machinit)


# machinit — macOS bootstrap & dotfiles installer

> A curated macOS bootstrap and dotfiles installer designed for reproducible, opinionated developer setups. Includes a safe installer flow, shell aliases & functions, zsh completions, and a test harness to validate changes.

Key goals:
- reproducible machine setup for dev environments
- safe, audit-friendly defaults with a DRY_RUN (dry-run) mode
- curated CLI completions, aliases, and helper scripts for productivity

---

## Quick start

1. Clone the repo and run the installer:

```bash
git clone https://github.com/supermarsx/machinit.git
cd machinit
chmod +x install.sh
./install.sh
```

2. See what would change without applying anything:

```bash
./install.sh --dry-run
```

3. Customize `config.toml` before running for any machine-specific settings.


## What this repo contains (short)

- `install.sh` — top-level orchestrator (supports flags like `--dry-run`, `--resume-failure`, `--clear-logs`).
- `scripts/` — many ordered scripts to install packages, configure system settings, and apply UI customizations.
- `assets/` — dotfiles, zsh completion files, themes, and templates.
- `dev_scripts/` — test, fetcher, and maintenance helpers (fetch completions, run the test harness, linting helpers).
- `dev_scripts/generate_inventory.py` — generates a current list of aliases, functions, completions, install targets and defaults into `docs/inventory.md` (run locally to refresh).
- `tests/` — local test harness that validates non-destructive behavior (safely using DRY_RUN).

---

## Global gitignore

This repository provides a recommended global gitignore at `assets/.gitignore_global`. It is intended as a sensible default for macOS developer machines and includes common ignores for:

- OS files and caches (macOS)
- Editors / IDEs (VS Code, JetBrains/IntelliJ/Android Studio)
- Language/tool build artifacts (Node.js, Python, Rust, Go, Java/Gradle, Ruby/Rails, PHP/Composer)
- Mobile/tooling (Android/Kotlin, Xcode/iOS)
- Containers / infra (Docker, Terraform)
- Environment and secret files (e.g. `.env`, private keys)

How to use it locally as your global excludes file:

```bash
cp assets/.gitignore_global ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
```

Notes:
- The file is meant to be a convenient starting point — review and customize it for your workflow before applying globally.
- It intentionally does not ignore dependency lockfiles (e.g. `package-lock.json`, `Gemfile.lock`, `Cargo.lock`) since those are commonly committed for reproducible builds.
- Contributions and additions are welcome; keep unrelated repo-specific ignores out of the global file.

## Functions

The following helper functions are provided in `assets/.functions`. Source that file into your shell (`source /path/to/machinit/assets/.functions`) to make these available in your interactive session.

- `mkd` — create a new directory (with parents) and immediately `cd` into it.
- `cdf` — change working directory to the top-most Finder window location (macOS Finder integration).
- `targz` — create a `.tar.gz` archive using `zopfli`, `pigz` or `gzip` (chooses best available compressor).
- `fs` — show size of a file or total size of a directory in a human-readable form (portable `du` wrapper).
- `diff` — use Git’s colored diff when available (`git diff --no-index --color-words`).
- `dataurl` — produce a data URL (base64) from a file; sets proper mime-type for text files.
- `server` — start a simple HTTP server (Python) from the current directory and open it in a browser; enables CORS.
- `gz` — compare original and gzipped file sizes and print ratio.
- `digga` — run `dig` with useful flags to show concise DNS answers.
- `getcertnames` — print the Common Name and Subject Alternative Names from an HTTPS certificate for a domain.
- `o` — `open` wrapper: `o` opens the current directory if called without args, otherwise opens its arguments.
- `tre` — enhanced `tree` alias: show hidden files, color, ignore `.git` and `node_modules`, view with `less`.
- `generate_git_key` — interactive helper to generate a new SSH key (ed25519), add it to the ssh-agent/keychain, and instruct how to add the public key to GitHub.
- `myaliases` — print a formatted table of aliases and functions (supports `--aliases`, `--functions`, `--all`).
- `findPid` — helper to find process IDs by process name/regex (uses `lsof -t -c`).
- `recent` — `cd` to the most recently modified project directory under `~/Projects` (supports indexing and name patterns).
- `ll` — robust `ls` wrapper that prefers GNU `ls`/`gls` but falls back safely for BSD systems.
- `myip` — robust public IP lookup with multiple service fallbacks and optional IPv6 support.


These functions are written to be safe for interactive shells (bash/zsh). If you rely on shell-specific features, consider sourcing the file from the appropriate rc file (e.g. `~/.zshrc` or `~/.bashrc`).

## Aliases

The following aliases are provided in `assets/.aliases` for quick command-line shortcuts.

Note: these aliases live in `assets/.aliases`. Source this file from your shell rc to enable them (for example, add `source /path/to/machinit/assets/.aliases` to `~/.zshrc` or `~/.bashrc`). The file is intended to be compatible with both bash and zsh; do not execute it directly because aliases defined in a subshell will not persist in your interactive shell.

- `bup` — `brew update && brew upgrade && brew cleanup` — update Homebrew, upgrade packages, cleanup
- `reloaddns` — `dscacheutil -flushcache && sudo killall -HUP mDNSResponder` — flush macOS DNS cache and restart `mDNSResponder` (requires `sudo`)
- `dnsreload` — `dscacheutil -flushcache && sudo killall -HUP mDNSResponder` — flush macOS DNS cache and restart `mDNSResponder` (requires `sudo`)
- `timestamp` — `date +%s` — print current epoch timestamp (seconds since UNIX epoch)
- `jsrefresh` — `rm -rf node_modules/ package-lock.json && npm install` — remove node deps and reinstall

Navigation:
- `..` — `cd ..` — go up one directory
- `...` — `cd ../../..` — go up two levels
- `....` — `cd ../../../../` — go up three levels
- `.....` — `cd ../../../../` — go up deeper (lenient duplicate)
- `cd..` — `cd ..` — alternate form to go up one
- `~` — `cd ~` — go to home directory
- `~~` — `cd -` — switch to previous working directory (use `~~` to go to the previous dir)

Shortcuts:
- `c` — `clear` — clear terminal screen
- `h` — `history` — display shell history
 

Zsh / config editors:
- `zshconf` — `nano ~/.zshrc` — open zsh configuration for quick edits

Project navigation:
- `projects` — `cd ~/Projects` — change to `~/Projects`
- `repos` — `cd ~/Projects` — same as `projects`

Common folders:
- `docs` — `cd ~/Documents` — go to `~/Documents`
- `downloads` — `cd ~/Downloads` — go to `~/Downloads`
- `dl` — `cd ~/Downloads` — short form to go to `~/Downloads`

Helpers:
- `qfind` — `find . -name` — find files by name in current dir
- `lsock` — `sudo lsof -i -P` — list network sockets (requires sudo)

Network:
- `ping_test` — `ping 1.1.1.1` — quick ping to Cloudflare DNS
- `localip` — `ipconfig getifaddr en0` — show local IP address for primary interface (macOS)

NPM shortcuts:
- `ni` — `npm install` — shorthand to install npm dependencies
- `nps` — `npm start` — shorthand to run `npm start`

Diagnostics & fun:
- `wtf` — `dmesg | tail` — show last kernel messages
- `up` — `echo "Time is an illusion."; uptime` — prints a fun message then shows uptime

Clipboard emoticons:
- `shrug` — `echo "¯\\_(ツ)_/¯" | pbcopy` — copy shrug emoticon to clipboard
- `tableflip` — `echo "(╯°□°）╯︵ ┻━┻" | pbcopy` — copy tableflip emoticon to clipboard
- `fix` — `echo "┬─┬ ノ( ゜-゜ノ)" | pbcopy` — copy fix emoticon to clipboard

Utilities:
- `entropy` — `openssl rand -base64 64` — generate 64 bytes of base64 randomness
- `void` — `>/dev/null 2>&1` — shortcut for discarding output
- `fractal` — `open -a Terminal .` — open current folder in Terminal
- `eldritchterror` — `open https://en.wikipedia.org/wiki/Heat_death_of_the_universe` — open doom article

System:
- `path` — `echo -e ${PATH//:/\\n}` — print PATH entries one-per-line (uses `${PATH//:/\\n}` which is supported in bash and zsh)
- `cpu` — `top -o cpu` — show top processes by CPU
- `mem` — `top -o rsize` — show top processes by memory usage (resident size)

- `afk` — `pmset displaysleepnow` — put display to sleep / lock screen
- `wifi_pass` — `security find-generic-password -wa` — retrieve WiFi password from keychain (append SSID)
 
## Completions

The `assets/completions/` directory contains curated zsh completion scripts included with these dotfiles. Install or source them into your shell to get improved tab completion for many common commands.

Included completion scripts (filename -> purpose):

- `_git` — Git CLI: subcommands and options completion.
- `_npm` — npm: curated npm subcommands and package.json helpers.
- `_node` — Node.js: official node CLI completion.
- `_copilot` — Copilot CLI: GitHub/AWS Copilot command completion.
- `_nvm` — Node Version Manager: install/use/list completions.
- `_npx` — npx: run binaries from node_modules with completion.
- `_yarn` — yarn: common yarn commands.
- `_cargo` — Cargo (Rust): build/test/run/etc. completions.
- `_rustc` — rustc: compiler flags and options.
- `_clang` / `_clang++` — Clang/Clang++: compiler options.
- `_gcc` / `_g++` — GCC/G++: compiler and linker flags.
- `_cmake` — CMake: generator and target completions.
- `_gnumake` — GNU make: common targets and options.
- `_vcpkg` — vcpkg: package manager completions for C/C++.
- `_black` / `_flake8` — Python tooling (formatter/linter) completions.
- `_grep` / `_egrep` / `_fgrep` — grep-family completions (search tools).
- `_rg` / `_ripgrep` — ripgrep: fast recursive search completion.
- `_ssh` — ssh client completions (hosts, options).
- `_curl` — curl: URL/option completions and common flags.
- `_wget` — wget: download utility completions.
- `_tar` — tar: archive operations and options.
- `_rsync` — rsync: sync options and remote/target completions.
- `_ip` / `_ipconfig` — network tools (ip/ipconfig) completions.
- `_ping` / `_dig` / `_nslookup` — DNS and network diagnostic completions.
- `_df` / `_du` — disk utilities completions.
- `_cat` / `_dd` / `_hexdump` — raw file utilities completions.
- `_code` / `_gh` / `_github` / `_opencode` / `_codex` — editor & GitHub/CLI completions.
- `_cron` / `_crontab` — cron scheduling helpers and crontab completions.
- `_dockutil` — macOS Dock utility completions.
- `_nvram` / `_ifconfig` — macOS system utilities completions.

Note: Some completions are auto-generated or derived from upstream sources; where available the scripts prefer a tool's native completion output. For the full list, see the `assets/completions/` folder.

## Installed Apps

These are the GUI apps and developer tools the installer can install (via Homebrew Casks or other helpers). Each entry references the script that performs the install in `scripts/`.

### Editors & IDEs

- `Visual Studio Code` — popular, extensible code editor with many extensions. (`scripts/021_install_vscode.sh`)
- `OpenCode` — a lightweight code editor/tooling package installed via Homebrew. (`scripts/023_install_opencode.sh`)
- `Mark Text` — an open-source WYSIWYG Markdown editor for writing and previewing Markdown. (`scripts/010_install_apps.sh`)

### Terminal & Shells

- `iTerm2` — a feature-rich terminal emulator for macOS with profiles, tabs and split panes. (`scripts/010_install_apps.sh`)
- `PowerShell` — Microsoft's cross-platform shell and scripting environment. (`scripts/007_install_powershell.sh`)

### Browsers & Web Tools

- `Google Chrome` — the Chromium-based web browser. (`scripts/028_install_google_chrome.sh`)
- `Chrome DevTools MCP` — Chrome DevTools helper/utility installed for browser development workflows. (`scripts/027_install_chrome_devtools_mcp.sh`)

### Office & Productivity

- `Microsoft Word` — word processing application from Microsoft Office. (`scripts/035_install_microsoft_word.sh`)
- `Microsoft Excel` — spreadsheet application from Microsoft Office. (`scripts/032_install_microsoft_excel.sh`)
- `Microsoft PowerPoint` — presentation application from Microsoft Office. (`scripts/034_install_microsoft_powerpoint.sh`)
- `Microsoft Outlook` — email and calendar client from Microsoft Office. (`scripts/033_install_microsoft_outlook.sh`)
- `Standard Notes` — an encrypted note-taking application focused on privacy and sync. (`scripts/010_install_apps.sh`)
- `Adobe Acrobat Reader` — a PDF reader for viewing and annotating PDFs. (`scripts/036_install_adobe_reader.sh`)

### Communication

- `Beeper` — chat/IM aggregation client that can bridge multiple services. (`scripts/024_install_beeper.sh`)
- `GitHub Desktop` — graphical Git client for GitHub workflows. (`scripts/025_install_github_desktop.sh`)

### Dev Tooling & Runtimes

- `nvm (Node Version Manager)` — manage multiple Node.js versions per-user. (`scripts/004_install_nvm.sh`)
- `Rust (rustup)` — installs the Rust toolchain using `rustup` (compiler, Cargo, toolchains). (`scripts/005_install_rust.sh`)
- `vcpkg` — C/C++ package manager for native dependencies. (`scripts/006_install_vcpkg.sh`)
- `OpenAI Codex CLI` — CLI tooling for interacting with the Codex/AI helper (where available). (`scripts/022_install_codex.sh`)

### Networking & Security

- `OpenVPN Connect` — official OpenVPN client for connecting to OpenVPN servers. (`scripts/037_install_openvpn.sh`)

### Sync & Storage

- `Nextcloud` — desktop sync client for Nextcloud file sync services. (`scripts/029_install_nextcloud.sh`)

### Fonts & System

- `Fantasque Sans Mono` — a bundled monospace font installed for development/terminal use. (`scripts/009_install_fonts.sh`)


## Test harness & CI

We validate changes using the test harness `dev_scripts/test.sh`. This script discovers tests under `tests/` and runs them in a safe manner.

Common commands:

```bash
# Run all tests (shell + python where applicable)
./dev_scripts/test.sh

# Run only completion-related tests and print output
./dev_scripts/test.sh --pattern completions --verbose

# Use the pytest mode for python tests when helpful
./dev_scripts/test.sh --pytest
```

Local development checklist:

1. Make edits to completions, scripts, dotfiles
2. Run linting: `./dev_scripts/lint.sh`
3. Run focused tests: `./dev_scripts/test.sh --pattern completions --verbose`
4. If everything passes, commit and open a PR

CI note: the repository has a GitHub Actions pipeline that runs these tests for PRs and pushes — keep changes test-friendly and DRY_RUN-safe.

---

## Contributing

We welcome contributions — typical flows:

1. Fork and create topic branch.
2. Make small, well-scoped changes (completions, scripts, docs, tests).
3. Add/adjust tests in `tests/` to exercise changes, prefer DRY_RUN-friendly assertions.
4. Run the test harness locally and ensure green CI.

Developer tips:

- Keep completions conservative and offline-friendly (avoid network calls during shell completion evaluation).
- Use `dev_scripts/fetch_completions.py` to fetch or regenerate helpful completions.
- If replacing an existing completion file, keep a backup copy or prefer `.generated` suffix until changes are validated.

---

## Security & Notes

This installer makes system-level changes and should be audited carefully before running. Use `--dry-run` and test on disposable machines or VMs if in doubt.

---

## License

MIT — see `license.md`.

---

If you'd like, I can also generate:
- a single cheat-sheet markdown (commands + flags) for tools we polished (e.g., Copilot, Codex, OpenCode), or
- machine-readable JSON/YAML specifications for completions (useful for generating richer completions).
