# Galaxyviewer

## Installation

Place the following files: /data/ folder, galaxymapper.py, modinfo.lua and this very file, into %Appdata%/Roaming/Avorion/mods/ (or the linux equivalent)

Then find and enable "galaxyviewer" viewer mod.

Enter in chat:
/mapgalaxy

Wait for it to tell you that it saved the file. The file should end up in the same folder as your clientlog.

Then execute galaxymapper.py (requires python3 and the "Pillow" module) and you will get a 4000x4000px representation of your Galaxies sectors.

Mapping gates is currently off by default, because it takes 6 hours minimum to be created. You can turn it on by setting    SCANGATES = true   in /galaxymapper.lua
