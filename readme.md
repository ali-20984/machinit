![machinit banner](https://github.com/user-attachments/assets/4126f9e7-dc86-4024-b7c0-9ae04b3aeba5)

<br>
<br>

[![CI](https://img.shields.io/github/actions/workflow/status/supermarsx/machinit/.github/workflows/test-suite.yml?branch=main&style=flat-square)](https://github.com/supermarsx/machinit/actions/workflows/test-suite.yml)
[![Made with Shell & Tears](https://img.shields.io/badge/made%20with-Shell%20%26%20Tears-ffa500?style=flat-square)](https://github.com/supermarsx/machinit)
[![DRY-RUN safe](https://img.shields.io/badge/DRY--RUN-SAFE-brightgreen?style=flat-square)](./tests/test_dry_run_protection.sh)
[![Inventory](https://img.shields.io/badge/inventory-docs-green?style=flat-square)](docs/inventory.md)
[![GitHub stars](https://img.shields.io/github/stars/supermarsx/machinit?style=flat-square)](https://github.com/supermarsx/machinit/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/supermarsx/machinit?style=flat-square)](https://github.com/supermarsx/machinit/network/members)
[![GitHub watchers](https://img.shields.io/github/watchers/supermarsx/machinit?style=flat-square)](https://github.com/supermarsx/machinit/watchers)
[![Open issues](https://img.shields.io/github/issues/supermarsx/machinit?style=flat-square)](https://github.com/supermarsx/machinit/issues)

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
- `o` — `open .` — open current directory in Finder (macOS)

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
