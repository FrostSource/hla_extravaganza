# FGD Files

> FGD files describe information about entities for the Hammer editor. These files are modified to improve the experience of mapping in Half-Life: Alyx.

### Notable changes

* Updated property/IO descriptions for all entities as we discover their uses.
* New `player_input_helper` editor entity to provide !player input descriptions.
* New `Weapons` category containing the 4 common weapon item entities.
* Certain entities that couldn't be simulated (like item_hlvr_weapon_energygun) can now be simulated.

---

## Installation

Navigate to your Half-Life: Alyx hlvr game directory, commonly:
`steamapps\common\Half-Life Alyx\game\hlvr`
Overwrite the currently existing `hlvr.fgd` with the file found here of the same name.

You can make a backup of the original file before doing so or get Steam to redownload it by right clicking Half-Life: Alyx within Steam and going to `Properties... > Local Files > Verify integrity of game files...`