#!/usr/bin/env python3
"""
install.py — Symlinks JukeboxCrush.ny into the Audacity plug-ins directory.
Works on Windows, macOS, and Linux.

Windows note: run as Administrator (or the script will prompt you to).
Linux/macOS:  the script will use sudo if the system path is needed.
"""

import ctypes
import os
import platform
import subprocess
import sys

PLUGIN = "JukeboxCrush.ny"
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(SCRIPT_DIR, PLUGIN)
OS = platform.system()  # "Windows" | "Darwin" | "Linux"


def plugin_dirs():
    """Return candidate plug-in dirs, preferred first."""
    home = os.path.expanduser("~")

    if OS == "Windows":
        appdata = os.environ.get("APPDATA", os.path.join(home, "AppData", "Roaming"))
        program_files = os.environ.get("PROGRAMFILES", r"C:\Program Files")
        return [
            os.path.join(appdata, "Audacity", "Plug-Ins"),
            os.path.join(program_files, "Audacity", "Plug-Ins"),
        ]

    if OS == "Darwin":
        return [
            os.path.join(home, "Library", "Application Support", "audacity", "Plug-Ins"),
            "/Library/Application Support/audacity/plug-ins",
            "/Applications/Audacity.app/Contents/plug-ins",
        ]

    # Linux
    return [
        os.path.join(home, ".audacity-data", "Plug-Ins"),
        "/usr/share/audacity/plug-ins",
        "/usr/local/share/audacity/plug-ins",
    ]


def is_writable(path):
    parent = path if os.path.isdir(path) else os.path.dirname(path)
    while parent and not os.path.exists(parent):
        parent = os.path.dirname(parent)
    return os.access(parent, os.W_OK)




def create_symlink(src, dest_file, use_sudo):
    # Remove stale symlink first
    if os.path.islink(dest_file):
        if os.readlink(dest_file) == src:
            print(f"  ✓ Already linked: {dest_file}")
            return True
        if use_sudo:
            subprocess.run(["sudo", "rm", dest_file], capture_output=True)
        else:
            os.remove(dest_file)

    if OS == "Windows":
        # Requires Developer Mode or Administrator
        try:
            os.symlink(src, dest_file)
        except OSError as e:
            print(f"  ✗ Symlink failed ({e}). Try running as Administrator.")
            return False
    elif use_sudo:
        print("  → Need sudo for system path (you may be prompted for your password)...")
        r = subprocess.run(["sudo", "ln", "-sf", src, dest_file], capture_output=True, text=True)
        if r.returncode != 0:
            print(f"  ✗ sudo failed: {r.stderr.strip()}")
            return False
    else:
        os.symlink(src, dest_file)

    print(f"  ✓ Linked: {dest_file}")
    print(f"       → {src}")
    return True


def windows_is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except Exception:
        return False


def main():
    if not os.path.isfile(SRC):
        print(f"Error: {PLUGIN} not found at {SRC}")
        sys.exit(1)

    if OS == "Windows" and not windows_is_admin():
        print("⚠  On Windows, symlinks usually require Administrator privileges.")
        print("   Right-click install.py → 'Run as administrator', or enable Developer Mode.\n")

    print(f"Installing {PLUGIN} on {OS}...\n")

    for target_dir in plugin_dirs():
        dest_file = os.path.join(target_dir, PLUGIN)
        need_sudo = OS != "Windows" and not is_writable(target_dir)

        print(f"  Trying: {target_dir}")
        if not os.path.isdir(target_dir):
            print(f"  ✗ Directory does not exist, skipping.\n")
            continue

        if create_symlink(SRC, dest_file, use_sudo=need_sudo):
            print("\n✅ Done! Restart Audacity, then:")
            print("   Effect → Plugin Manager → JukeboxCrush → Enable → OK")
            sys.exit(0)

        print()  # blank line before next attempt

    print("\n❌ All install paths failed.")
    if OS == "Windows":
        print(f"   Manually copy {PLUGIN} to: %APPDATA%\\Audacity\\Plug-Ins\\")
    elif OS == "Darwin":
        print(f"   Manually copy {PLUGIN} to: ~/Library/Application Support/audacity/Plug-Ins/")
    else:
        print(f"   Try: sudo ln -sf {SRC} /usr/share/audacity/plug-ins/{PLUGIN}")
    sys.exit(1)


if __name__ == "__main__":
    main()
