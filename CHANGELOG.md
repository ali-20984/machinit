# Changelog

All notable changes to this project are documented here.

## 2025-12-03 — main

### Added
- macOS CI: Added a full macOS `test-suite` job and `workflow_dispatch` in `.github/workflows/ci.yml` so maintainers can run the full test-suite on macOS runners and trigger it manually.
- Configurable Terminal Theme: `config.toml` now supports `[appearance] terminal_theme` with default `shades_of_fire`.
- iTerm2 support: `scripts/046_configure_iterm2.sh` and two presets (`assets/themes/shades_of_fire.itermcolors` and `charcoal.itermcolors`) added.
- `myip()` function: robust public IP lookup that cycles through multiple external services (`icanhazip.com`, `checkip.amazonaws.com`, `ifconfig.me`, `ident.me`, `ipinfo.io/ip`).
- `ni` alias: short alias for `npm install` added to `assets/.aliases`.
- `recent()` improvements: `recent` now supports numeric indices, `-n N` syntax, and name pattern matching; searches `~/Projects` and `~/Documents/Projects`.

### Changed
- README: improved license section detailing how bundled third-party assets are handled and added docs about theming and iTerm2 support.
- Tests: Added new tests for terminal theme config, iTerm2 presets, `myip`, and `ni` alias.

### Fixed
- Various CI/test enhancements and robustness fixes across dotfiles and installer scripts.

---

For previous history see commits on the `main` branch.
