#!/usr/bin/env python3
"""
install.py — Copies JukeboxCrush.ny into the Audacity plug-ins directory.
Run this after every change to push the latest version to Audacity.
Works on Windows, macOS, and Linux.

For symlinking instead, use install_link.py.
"""

import ctypes
import os
import platform
import shutil
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
    return os.access(path, os.W_OK)


def copy_plugin(src, target_dir, use_sudo):
    dest_file = os.path.join(target_dir, PLUGIN)

    if use_sudo:
        print("  → Need sudo (you may be prompted for your password)...")
        r = subprocess.run(["sudo", "cp", src, dest_file], capture_output=True, text=True)
        if r.returncode != 0:
            print(f"  ✗ sudo failed: {r.stderr.strip()}")
            return False
    else:
        shutil.copy2(src, dest_file)

    print(f"  ✓ Copied to: {dest_file}")
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
        print("⚠  On Windows, copying to Program Files may require Administrator privileges.")
        print("   Right-click install.py → 'Run as administrator' if it fails.\n")

    print(f"Installing {PLUGIN} on {OS}...\n")

    for target_dir in plugin_dirs():
        print(f"  Trying: {target_dir}")
        if not os.path.isdir(target_dir):
            print(f"  ✗ Directory does not exist, skipping.\n")
            continue

        need_sudo = OS != "Windows" and not is_writable(target_dir)

        if copy_plugin(SRC, target_dir, use_sudo=need_sudo):
            print("\n✅ Done! Restart Audacity (or use Effect → Rescan) to pick up changes.")
            sys.exit(0)

        print()

    print("\n❌ All install paths failed.")
    if OS == "Windows":
        print(f"   Manually copy {PLUGIN} to: %APPDATA%\\Audacity\\Plug-Ins\\")
    elif OS == "Darwin":
        print(f"   Manually copy {PLUGIN} to: ~/Library/Application Support/audacity/Plug-Ins/")
    else:
        print(f"   Try: sudo cp {SRC} /usr/share/audacity/plug-ins/{PLUGIN}")
    sys.exit(1)


if __name__ == "__main__":
    main()
