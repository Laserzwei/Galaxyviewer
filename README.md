# Galaxyviewer

## Installation

run
/run Entity():addScriptOnce("mods/Galaxyviewer/scripts/entity/galaxymapper.lua")

Wait for it to tell you that it saved the file. The file should end up in the same folder as your clientlog.

Then execute galaxymapper.py (requires python3 and the "Pillow" module) and you will get a 4000x4000px representation of your Galaxies sectors.

Mapping gates is currently off by default, because it takes 6 hours minimum to be created. You can turn it on by setting    SCANGATES = true   in /galaxymapper.lua
