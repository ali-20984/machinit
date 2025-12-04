## Convenience helpers

- `myaliases` — show the list of local `aliases` and `functions` with short descriptions pulled from inline comments. Usage: `myaliases`, `myaliases --aliases`, `myaliases --functions`

# Aliases and Functions (machinit)

This document is a consolidated reference for the small shell aliases and helper functions defined in the dotfiles under `assets/`.

- Alias definitions: `assets/.aliases`
- Shell function definitions: `assets/.functions`

If you maintain these files, please keep them well-commented and add new items to this doc.

Note: The repository includes a conflict-checker `scripts/011_check_aliases_functions_conflicts.sh`.
By default the checker writes a report and runs in *warning-only* mode (it will not abort on conflicts).
The installer runs the checker with `--abort-on-conflict` before applying dotfiles so the installation will
abort if conflicts are detected. You can run the checker manually and control behavior:

- `bash scripts/011_check_aliases_functions_conflicts.sh` — run checker (warning-only; writes report)
- `bash scripts/011_check_aliases_functions_conflicts.sh --check-only` — run checker and exit (warning-only)
- `bash scripts/011_check_aliases_functions_conflicts.sh --abort-on-conflict` — exit non-zero if conflicts found (installer uses this)
abort unless `SKIP_ALIAS_CHECK=1` is set in your environment.

---

## Aliases (quick reference)

alias | description
---|---
bup | Update Homebrew, upgrade installed packages and cleanup
shrug | Copy `¯\_(ツ)_/¯` to clipboard (macOS)
reloaddns / dnsreload | Flush macOS DNS cache and restart mDNSResponder
timestamp | Print the current epoch timestamp
jsrefresh | Remove node_modules and package-lock.json, then `npm install`
.. / ... / .... / ..... | Directory up-navigation helpers (incrementally higher)
cd.. | Alias that also changes directory up one level
~ | Go home directory
- (dash) | `cd -` — switch to previous directory
c | Clear terminal
docs | Quick navigation to `~/Documents`
downloads | Quick navigation to `~/Downloads`
dl | Short form for `cd ~/Downloads`
h | Show shell history
o | Open the current directory in Finder (macOS)
zshconf | Edit `~/.zshrc`
projects / repos | `cd ~/Projects` (project root shortcut)
qfind | Quick wrapper `find . -name` to search by filename
lsock | Show open sockets (requires sudo)
ping_test | Quick ping to `1.1.1.1` (Cloudflare)
localip | `ipconfig getifaddr en0` (macOS local interface ip)
ni | `npm install` (short)
nps | `npm start` (short) - start the project's dev server
wtf | `dmesg | tail` - show most recent kernel messages ("What just happened?")
up | print a cheeky message then run `uptime` on the next line
tableflip | `echo "(╯°□°）╯︵ ┻━┻" | pbcopy` - copy tableflip emoticon to clipboard (macOS)
fix | `echo "┬─┬ ノ( ゜-゜ノ)" | pbcopy` - copy fix emoticon to clipboard (macOS)
entropy | `openssl rand -base64 64` - generate strong base64 entropy for keys
void | redirect output to `/dev/null` (convenience redirection alias for pipelines)
fractal | `open -a Terminal .` - open the current folder in Terminal (macOS)
eldritchterror | `open https://en.wikipedia.org/wiki/Heat_death_of_the_universe` - open a doom reading in the browser
path | Print PATH entries one-per-line
cpu | `top -o cpu` (top processes by CPU usage)
mem | `top -o rsize` (top processes by memory usage)
afk | Put display to sleep / lock the screen
wifi_pass | Show WiFi password from macOS keychain: `security find-generic-password -wa <SSID>`


## Shell functions (detailed)

Name | Purpose / notes | Example usage
---|---|---
mkd | Create a directory (including parents) and `cd` into it | `mkd new_project/subdir`
cdf | CD to the location opened in Finder (macOS only) | `cdf`
targz | Create a `.tar.gz` archive. Uses `zopfli`, `pigz` or `gzip` depending on availability and size; excludes `.DS_Store` | `targz folder_to_archive`
fs | Show file/directory sizes using `du` and readable flags depending on system utilities | `fs .`, `fs some/file`
(diff - git-aware) | If `git` exists, `diff` uses `git diff --no-index --color-words` for pretty, colored diffs | `diff file1 file2`
dataurl | Convert a file to a base64 data URL (incl. proper MIME type) | `dataurl image.png`
server | Start a little HTTP server (Python3) with a permissive CORS header; opens browser | `server 8080`
gz | Show original size, gzipped size and compression ratio | `gz bigfile.bin`
digga | Run `dig` for DNS and show useful answer information | `digga example.com`
getcertnames | Connect to a host via TLS and print CN and SAN entries from the certificate | `getcertnames example.com`
o | `open` wrapper — no args opens current dir, otherwise opens target path (macOS Finder)
tre | `tree` shorthand with hidden files, colors and useful ignores; pipes to `less` when output is large | `tre` or `tre src`
generate_git_key | Interactive helper to create an ed25519 SSH key, add to ssh-agent and print next steps | `generate_git_key you@example.com`
findPid | Find process IDs that match a process name (regex) using `lsof -t -c` | `findPid '/d$/'`
recent | CD to most recently modified project dir in `~/Projects` or `~/Documents/Projects`; supports numeric indexing and pattern matching | `recent` or `recent 2` or `recent myproj`
ll | Portable, robust `ls` (prefers GNU `ls`/gls with color and directories first) | `ll -A` or `ll` default
myip | Find your public IP using a list of known services; supports `--service` and `--ipv6` | `myip --service aws` or `myip --ipv6`
extract_ip (internal) | Internal helper used by `myip` that parses IPs or JSON responses for plausible addresses | n/a (internal)

---

## Notes & suggestions

- `assets/.aliases` should remain alias-only; keep functions in `assets/.functions` as they are now.
- When adding complex logic, prefer creating unit-testable scripts in `scripts/` and keep `assets/.functions` for small convenience helpers.
- Consider adding small examples / tests for critical helpers (e.g. `myip`, `generate_git_key`) in `tests/` if you need regression coverage.

If you'd like, I can:
- Add short tests for `myip` and `recent` behaviors.
- Expand examples and edge-case explanations for each helper.
