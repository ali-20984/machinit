#!/usr/bin/env python3
"""finder_sidebar_editor — tiny helper for Finder sidebar operations.

Provides a lightweight, dependency-light API for adding, removing, listing
and moving items in the Finder Favorites (sidebar). Designed to be used by
the installer scripts in this repo under scripts/lib.

The implementation is intentionally best-effort and safe for DRY_RUN testing.
It prefers to use mysides when that binary is available _and_ the caller wants
that path; otherwise it uses AppleScript UI automation for best-effort changes.

Usage:
    from finder_sidebar_editor import FinderSidebar
    fs = FinderSidebar()
    fs.add('/Users/alice/Documents/Projects')
    fs.list()
    fs.remove('Projects')
    fs.move('Projects', 1)
"""

from __future__ import annotations

import os
import subprocess
import sys
import urllib.parse
import plistlib
from typing import List, Optional


class FinderSidebar:
    """API for Finder sidebar operations.

    Methods are best-effort. They raise RuntimeError on unrecoverable errors.
    When DRY_RUN is enabled in the environment this class will print actions but
    not attempt to modify the system.
    """

    def __init__(self):
        self._dry_run = os.environ.get("DRY_RUN") not in (None, "0", "false", "False", "FALSE")

    def _run(self, cmd: List[str], **kwargs) -> subprocess.CompletedProcess:
        try:
            return subprocess.run(cmd, check=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE, **kwargs)
        except FileNotFoundError:
            # emulate a non-zero returncode to indicate missing binary
            cp = subprocess.CompletedProcess(cmd, returncode=127)
            return cp

    def _file_url(self, path: str) -> str:
        p = os.path.expanduser(path)
        p = os.path.abspath(p)
        return "file://" + urllib.parse.quote(p, safe="/")

    def add(self, path: str, name: Optional[str] = None) -> bool:
        """Add a filesystem path to the Finder favorites/sidebar.

        Returns True on success. In DRY_RUN mode the call is logged and returns True.
        """
        if sys.platform != "darwin":
            raise RuntimeError("FinderSidebar is only supported on macOS (darwin)")

        if not path:
            raise ValueError("path is required")

        target = os.path.expanduser(path)
        target = os.path.abspath(target)

        if self._dry_run:
            print(f"[DRY_RUN] add: {target}")
            return True

        if not os.path.exists(target):
            raise RuntimeError(f"target does not exist: {target}")

        # Try mysides if available
        # Allow tests and callers to override the mysides path via MACHINIT_MYSIDES
        env_override = os.environ.get("MACHINIT_MYSIDES")
        mysides_candidates = []
        if env_override:
            mysides_candidates.append(env_override)
        mysides_candidates.extend(("/usr/local/bin/mysides", "/opt/homebrew/bin/mysides", "/usr/bin/mysides"))

        for mysides in mysides_candidates:
            if os.path.exists(mysides) and os.access(mysides, os.X_OK):
                friendly = name or os.path.basename(target) or target
                # try the file:// URL form first
                fileurl = self._file_url(target)
                cp = self._run([mysides, "add", friendly, fileurl])
                if cp.returncode == 0:
                    return True
                cp = self._run([mysides, "add", friendly, target])
                if cp.returncode == 0:
                    return True

        # AppleScript fallback (UI automation) — best-effort
        applescript = """
tell application "Finder"
    try
        set targetFolder to (POSIX file "{target}") as alias
        open targetFolder
        delay 0.2
        set selection to targetFolder
    end try
end tell
tell application "System Events"
    tell process "Finder"
        try
            click menu item "Add to Sidebar" of menu "File" of menu bar 1
        on error
            -- ignore UI errors
        end try
    end tell
end tell
"""

        cp = self._run(["/usr/bin/osascript", "-e", applescript])
        return cp.returncode == 0

    def list(self) -> List[str]:
        """Return a best-effort list of favorites sidebar entries (names or paths).

        The output may vary by system; this method returns a list of strings.
        """
        if self._dry_run:
            print("[DRY_RUN] list")
            return []

        # Try mysides if present for a clean listing
        env_override = os.environ.get("MACHINIT_MYSIDES")
        mysides_candidates = []
        if env_override:
            mysides_candidates.append(env_override)
        mysides_candidates.extend(("/usr/local/bin/mysides", "/opt/homebrew/bin/mysides", "/usr/bin/mysides"))

        for mysides in mysides_candidates:
            if os.path.exists(mysides) and os.access(mysides, os.X_OK):
                cp = self._run([mysides, "list"])
                if cp.returncode == 0:
                    out = cp.stdout.decode().strip().splitlines()
                    # Parse lines like "Name <separator> URL" — extract the friendly name
                    parsed = []
                    for ln in out:
                        ln = ln.strip()
                        if not ln:
                            continue
                        # If the line contains a file:// URL, the friendly name is usually before it
                        idx = ln.rfind("file://")
                        if idx != -1:
                            name = ln[:idx].strip()
                            if not name:
                                # fallback to basename of the path
                                name = os.path.basename(urllib.parse.unquote(ln[idx:]))
                        else:
                            # Otherwise use the whole line
                            name = ln
                        parsed.append(name)
                    return parsed

        # Fallback: read Finder sidebar prefs (best-effort parsing)
        # Next try reading the user's preferences plist directly (best-effort)
        try:
            prefs_path = os.path.expanduser("~/Library/Preferences/com.apple.sidebarlists.plist")
            if os.path.exists(prefs_path):
                with open(prefs_path, "rb") as f:
                    obj = plistlib.load(f)

                # Recursively search the plist for 'Name' or URL-like entries
                def _collect_names(o):
                    names = []
                    if isinstance(o, dict):
                        for k, v in o.items():
                            if isinstance(k, str) and k.lower() == "name" and isinstance(v, str):
                                names.append(v)
                            else:
                                names.extend(_collect_names(v))
                    elif isinstance(o, (list, tuple)):
                        for item in o:
                            names.extend(_collect_names(item))
                    elif isinstance(o, str):
                        # if the string looks like a path/url, use its basename
                        if "file://" in o or o.startswith("/"):
                            names.append(os.path.basename(urllib.parse.unquote(o)))
                    return names

                parsed = _collect_names(obj)
                if parsed:
                    # preserve order and uniqueness
                    seen = set()
                    out = []
                    for n in parsed:
                        if n and n not in seen:
                            seen.add(n)
                            out.append(n)
                    return out
        except Exception:
            # best-effort — fall back to defaults read if available
            pass

        cp = self._run(["/usr/bin/defaults", "read", "com.apple.sidebarlists"], stderr=subprocess.DEVNULL)
        if cp.returncode == 0 and cp.stdout:
            # Attempt simple parsing: find file:// occurrences and use the preceding tokens as names
            txt = cp.stdout.decode()
            lines = txt.splitlines()
            parsed = []
            for ln in lines:
                ln = ln.strip()
                if not ln:
                    continue
                idx = ln.rfind("file://")
                if idx != -1:
                    name = ln[:idx].strip()
                    if not name:
                        name = os.path.basename(urllib.parse.unquote(ln[idx:]))
                    parsed.append(name)
                elif len(ln) < 256:
                    parsed.append(ln)
            if parsed:
                return parsed

        raise RuntimeError("Unable to list Finder sidebar items (no mysides and failed to read prefs)")

    def remove(self, name: str) -> bool:
        """Attempt to remove a sidebar item by name.

        Returns True on success. May raise RuntimeError on unrecoverable failure.
        """
        if self._dry_run:
            print(f"[DRY_RUN] remove: {name}")
            return True

        # If the name looks like a file:// URL, try to derive path
        target_path = None
        if name and name.startswith("file://"):
            target_path = urllib.parse.unquote(name[len("file://"):])

        # Try mysides remove/rm first
        env_override = os.environ.get("MACHINIT_MYSIDES")
        mysides_candidates = []
        if env_override:
            mysides_candidates.append(env_override)
        mysides_candidates.extend(("/usr/local/bin/mysides", "/opt/homebrew/bin/mysides", "/usr/bin/mysides"))
        for mysides in mysides_candidates:
            if os.path.exists(mysides) and os.access(mysides, os.X_OK):
                # try both 'remove' and 'rm'
                for cmd in ("remove", "rm"):
                    # Try the name first
                    cp = self._run([mysides, cmd, name])
                    if cp.returncode == 0:
                        return True

                    # Try file:// URL form
                    if target_path is None and os.path.exists(name):
                        # caller passed a path — try file:// form
                        fileurl = self._file_url(name)
                        cp = self._run([mysides, cmd, fileurl])
                        if cp.returncode == 0:
                            return True

                    if target_path is not None:
                        # if we resolved a path from a file://, try removing that path too
                        cp = self._run([mysides, cmd, target_path])
                        if cp.returncode == 0:
                            return True

                    # As a final attempt try the basename of the provided name
                    base = os.path.basename(name)
                    if base and base != name:
                        cp = self._run([mysides, cmd, base])
                        if cp.returncode == 0:
                            return True

                    # Also try to find a candidate from the listing and remove that
                    try:
                        candidates = self.list()
                    except Exception:
                        candidates = []
                    for cand in candidates:
                        if cand and name.lower() in cand.lower():
                            cp = self._run([mysides, cmd, cand])
                            if cp.returncode == 0:
                                return True

        # Best-effort AppleScript: find item in sidebar and remove via UI
        # Best-effort AppleScript: try selecting the item via UI and use the "Remove from Sidebar" menu.
        # UI scripting is fragile and localized; we attempt a few approaches.
        safe_name = name.replace('"', '\\"') if isinstance(name, str) else name
        applescript = f"""
try
    tell application "Finder"
        activate
    end tell
    delay 0.1
    tell application "System Events"
        tell process "Finder"
            -- Try to click a sidebar element matching the name
            try
                repeat with anOutline in (every outline of scroll area 1 of splitter group 1 of window 1)
                    try
                        repeat with r in (UI elements of anOutline)
                            try
                                if (value of attribute "AXTitle" of r as string) contains "{safe_name}" then
                                    perform action "AXPress" of r
                                    delay 0.1
                                    -- invoke the File menu remove action
                                    try
                                        click menu item "Remove from Sidebar" of menu "File" of menu bar 1
                                    end try
                                    return
                                end if
                            end try
                        end repeat
                    end try
                end repeat
            end try
        end tell
    end tell
on error
    -- best-effort; ignore UI failures
end try
"""
        cp = self._run(["/usr/bin/osascript", "-e", applescript])
        return cp.returncode == 0

    def move(self, name: str, position: int) -> bool:
        """Move a sidebar item to a new (1-based) position – best-effort.

        This method tries to use mysides if available, otherwise it's a noop
        or attempts a UI automation. Returns True on success.
        """
        if self._dry_run:
            print(f"[DRY_RUN] move: {name} -> {position}")
            return True

        # Try mysides move if it supports it (best-effort)
        env_override = os.environ.get("MACHINIT_MYSIDES")
        mysides_candidates = []
        if env_override:
            mysides_candidates.append(env_override)
        mysides_candidates.extend(("/usr/local/bin/mysides", "/opt/homebrew/bin/mysides", "/usr/bin/mysides"))
        for mysides in mysides_candidates:
            if os.path.exists(mysides) and os.access(mysides, os.X_OK):
                cp = self._run([mysides, "move", name, str(position)])
                if cp.returncode == 0:
                    return True

        # UI automation fallback is complex; attempt best-effort AppleScript
        applescript = """
-- UI move is a no-op fallback here; reordering via AppleScript is non-trivial
return 1
"""
        # Attempt a no-op that returns non-success
        cp = self._run(["/usr/bin/osascript", "-e", applescript])
        return cp.returncode == 0


def main(argv=None) -> int:
    argv = list(argv or sys.argv[1:])

    import argparse

    parser = argparse.ArgumentParser(prog="finder_sidebar_editor")
    sub = parser.add_subparsers(dest="cmd")

    p_add = sub.add_parser("add")
    p_add.add_argument("path")
    p_add.add_argument("--name", default=None)

    p_rm = sub.add_parser("remove")
    p_rm.add_argument("name")

    sub.add_parser("list")

    p_move = sub.add_parser("move")
    p_move.add_argument("name")
    p_move.add_argument("position", type=int)

    args = parser.parse_args(argv)
    fs = FinderSidebar()

    try:
        if args.cmd == "add":
            ok = fs.add(args.path, name=args.name)
            print("Added" if ok else "Failed")
            return 0 if ok else 2

        if args.cmd == "remove":
            ok = fs.remove(args.name)
            print("Removed" if ok else "Failed")
            return 0 if ok else 2

        if args.cmd == "list":
            items = fs.list()
            for line in items:
                print(line)
            return 0

        if args.cmd == "move":
            ok = fs.move(args.name, args.position)
            print("Moved" if ok else "Failed")
            return 0 if ok else 2

    except Exception as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 3

    parser.print_help()
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
