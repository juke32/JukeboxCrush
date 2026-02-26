# JukeboxCrush

A Nyquist bitcrush plugin for Audacity featuring bit depth reduction, sample rate crushing, dynamic filtering, and lo-fi presets.

## Quick Install

```bash
python3 install.py
```

Symlinks `JukeboxCrush.ny` into Audacity's plug-ins folder — no need to re-run after editing the file.

| OS | Notes |
|----|-------|
| **Linux** | Prompts for `sudo` if the system path is used |
| **macOS** | Tries user path first, then system path with `sudo` |
| **Windows** | Run as Administrator, or enable Developer Mode in Windows Settings |

---

## Manual Installation

1. Download `JukeboxCrush.ny`
2. Copy it to your Audacity plug-ins folder:

   | OS | Path |
   |----|------|
   | **Windows** | `C:\Program Files\Audacity\Plug-Ins\` |
   | **macOS** | `/Applications/Audacity.app/Contents/plug-ins/` |
   | **Linux** | `/usr/share/audacity/plug-ins/` or `~/.audacity-data/Plug-Ins/` |

3. Open Audacity → **Effect menu** → **Plugin Manager** (or **Add / Remove Plug-ins…**)
4. Find **JukeboxCrush** in the list, set it to **Enabled**, click **OK**
5. It will now appear under **Effect → JukeboxCrush**

> **Tip:** On older Audacity versions (< 2.4) you may need to restart Audacity after copying the file — no Plugin Manager step required.


The install.py script is mainly for me to easily install the plugin on my linux machine. It's not required or reccomended to use it