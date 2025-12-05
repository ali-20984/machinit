#!/usr/bin/env python3
"""Generate an exhaustive inventory (aliases, functions, completions, apps, defaults)

Writes docs/INVENTORY.md containing machine-readable lists and a human-friendly summary.
"""
import os
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "assets"
SCRIPTS = ROOT / "scripts"
DOCS = ROOT / "docs"
DOCS.mkdir(exist_ok=True)

def parse_aliases(file):
    # Return list of (name, description) for aliases in file.
    aliases = []
    if not file.exists():
        return aliases
    with open(file, 'r') as fh:
        for line in fh:
            # strip trailing comments for description capture
            # Approach:
            #  - split on first '#' to extract an optional description (comment)
            #  - ensure the left-hand side starts with 'alias' and extract the name
            parts = line.split('#', 1)
            left = parts[0].strip()
            desc = (parts[1].strip() if len(parts) > 1 else '')

            if not left.startswith('alias'):
                continue

            try:
                # remove the leading `alias` keyword and any leading flags
                _, rest = left.split(None, 1)
            except ValueError:
                # malformed alias line
                continue

            # rest should look like name=value or -- -="value"
            # we only care about the name on the left side of '='
            if '=' in rest:
                name_part = rest.split('=', 1)[0].strip()
            else:
                name_part = rest.strip()

            # strip quotes if present
            name = name_part.strip().strip('"').strip("'")
            aliases.append((name, desc))
    return aliases

def parse_functions(file):
    # Returns list of (name, description) where description is the contiguous
    # comment block immediately preceding the function declaration (if any).
    funcs = []
    if not file.exists():
        return funcs
    lines = file.read_text().splitlines()
    for idx, line in enumerate(lines):
        m = re.match(r"^\s*function\s+([a-zA-Z0-9_]+)\s*\(", line)
        if not m:
            m2 = re.match(r"^\s*([a-zA-Z0-9_]+)\s*\(\)\s*\{", line)
            if m2:
                name = m2.group(1)
            else:
                continue
        else:
            name = m.group(1)

        # collect contiguous comment lines above
        desc_lines = []
        j = idx - 1
        while j >= 0 and lines[j].strip().startswith('#'):
            desc_lines.insert(0, lines[j].strip().lstrip('#').strip())
            j -= 1

        desc = ' '.join(desc_lines).strip()
        funcs.append((name, desc))
    return funcs

def list_completions():
    completions_dir = ASSETS / "completions"
    if not completions_dir.exists():
        return []
    return sorted([p.name.lstrip('_') for p in completions_dir.iterdir() if p.is_file() and p.name.startswith('_')])

def find_print_installs():
    installs = []
    rx = re.compile(r'print_install\s+"([^"]+)"')
    for f in SCRIPTS.glob('*.sh'):
        with open(f, 'r') as fh:
            for line in fh:
                m = rx.search(line)
                if m:
                    installs.append((f.name, m.group(1)))
    return installs

def find_defaults():
    defaults = set()
    # Capture set_default or set_user_default invocations while ignoring
    # commented lines. Keys can be quoted and may contain spaces, so handle
    # both quoted and unquoted keys.
    rx = re.compile(r'set_(?:user_)?default\s+(\S+)\s+(?:"([^"]+)"|\'([^\']+)\'|(\S+))')
    for f in SCRIPTS.glob('*.sh'):
        with open(f, 'r') as fh:
            for line in fh:
                # skip comment lines to avoid matching commented notes like
                # "Date handling in set_default is tricky..."
                if line.strip().startswith('#'):
                    continue

                m = rx.search(line)
                if m:
                    domain = m.group(1)
                    # key may be in group 2,3,4 depending on quoting
                    key = m.group(2) or m.group(3) or m.group(4)
                    if key:
                        defaults.add((domain, key))
    return sorted(defaults)

def main():
    aliases_file = ASSETS / '.aliases'
    functions_file = ASSETS / '.functions'

    # Normalise aliases -> list of (name, desc)
    aliases = [(name.lower(), desc) for (name, desc) in parse_aliases(aliases_file)]

    # Normalise functions from assets/.functions -> dict name -> desc
    functions_map = {name.lower(): desc for (name, desc) in parse_functions(functions_file)}
    # also include function names found inside scripts
    # Also include function names found inside scripts (preserve any existing descriptions
    # if not already present)
    for f in SCRIPTS.glob('*.sh'):
        for (name, desc) in parse_functions(f):
            lname = name.lower()
            if lname not in functions_map:
                functions_map[lname] = desc

    # Final functions list is a sorted list of tuples (name, desc)
    functions = sorted([(name, desc) for (name, desc) in functions_map.items()], key=lambda x: x[0])

    completions = [c.lower() for c in list_completions()]
    # Normalise install target names to lowercase
    installs = [(s, app.lower()) for (s, app) in find_print_installs()]
    # Normalise defaults domains and keys to lowercase
    defaults = [(d.lower(), k.lower()) for (d, k) in find_defaults()]

    out = DOCS / 'inventory.md'
    with open(out, 'w') as fh:
        fh.write('# MachInit Inventory\n\n')
        fh.write('Generated by dev_scripts/generate_inventory.py\n\n')

        fh.write('## Aliases (assets/.aliases)\n')
        if aliases:
            for (name, desc) in aliases:
                if desc:
                    fh.write(f'- `{name}` — {desc}\n')
                else:
                    fh.write(f'- `{name}`\n')
        else:
            fh.write('- (none)\n')
        fh.write('\n')

        fh.write('## Functions (assets/.functions + scanned scripts)\n')
        if functions:
            for (name, desc) in functions:
                if desc:
                    fh.write(f'- `{name}()` — {desc}\n')
                else:
                    fh.write(f'- `{name}()`\n')
        else:
            fh.write('- (none)\n')
        fh.write('\n')

        fh.write('## Completions (assets/completions)\n')
        if completions:
            for c in completions:
                fh.write(f'- `{c}`\n')
        else:
            fh.write('- (none)\n')
        fh.write('\n')

        fh.write('## App/install targets (detected via print_install in scripts/)\n')
        if installs:
            for s, app in installs:
                fh.write(f'- `{app}` (from `{s}`)\n')
        else:
            fh.write('- (none)\n')
        fh.write('\n')

        fh.write('## Defaults referenced (set_default / set_user_default)\n')
        if defaults:
            for domain, key in defaults:
                fh.write(f'- `{domain}` `{key}`\n')
        else:
            fh.write('- (none)\n')
        fh.write('\n')

        # small summary table
        fh.write('---\n')
        fh.write(f'- Aliases: {len(aliases)}\n')
        fh.write(f'- Functions: {len(functions)}\n')
        fh.write(f'- Completions: {len(completions)}\n')
        fh.write(f'- Install targets found: {len(installs)}\n')
        fh.write(f'- Default entries found: {len(defaults)}\n')

    print('WROTE:', out)

if __name__ == '__main__':
    main()
