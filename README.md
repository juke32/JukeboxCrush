# JukeboxCrush

A Nyquist bitcrush plugin for Audacity featuring bit depth reduction, sample rate crushing, dynamic filtering, and lo-fi presets.

<img width="495" height="263" alt="image" src="https://github.com/user-attachments/assets/1bd06708-ad4d-4799-8e97-1499d1bf9caf" />

## Nyquist Plugin Installer
Audacity has a built-in installer for Nyquist (`.ny`) files:

1. Open Audacity
2. Go to **Tools → Nyquist Plug-in Installer**
3. Click "Browse..." and select `JukeboxCrush.ny`
4. Set "Allow overwriting" to **Check** (if updating)
5. Click **Apply**
6. Restart Audacity or enable the plugin via **Effect → Plugin Manager**


## Manual Installation If Nyquist Plugin Installer doesn't work
1. Copy it to your Audacity plug-ins folder.
(may need admin rights to the folder, in linux open folder as admin or copy with commandline)
   | OS | Path |
   |----|------|
   | **Windows** | `C:\Program Files\Audacity\Plug-Ins\` |
   | **macOS** | `/Applications/Audacity.app/Contents/plug-ins/` |
   | **Linux** | `/usr/share/audacity/plug-ins/` or `~/.audacity-data/Plug-Ins/` or `/home/tom/.local/share/audacity/Plug-Ins/` |
2. Restart audacity
3. Look under Effects

### If it doesn't show up 
4. Open Audacity → **Effect menu** → **Plugin Manager** (or **Add / Remove Plug-ins…**)
5. Find **JukeboxCrush** in the list, set it to **Enabled**, click **OK**
6. It will now appear under **Effect → JukeboxCrush** (or restart again)



----

The install_copy.py script is mainly for me to easily install the plugin on my linux machine. It's not required or reccomended to use it


I am not affiliated with the following, but they are cool: https://websim.com/@katoneba/audio-bitcrusher
