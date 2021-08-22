# FGD Files

> ### FGD files describe information about entities for the Hammer editor. These files are modified to improve the experience of mapping in Half-Life: Alyx.

> `hlvr.fgd` is the main file with all the main improvements. `base.fgd` has some small extra changes that couldn't be easily changed in `hlvr.fgd` but are unlikely to be noticed.

### Notable changes

* Updated property/IO descriptions for all entities as I discover their uses.
* New `player_input_helper` editor entity to provide !player input descriptions.
* New `Weapons` category containing the 4 common weapon item entities.
* Certain entities that couldn't be simulated (like item_hlvr_weapon_energygun) can now be simulated.
* prop_physics `CanPhysPull`/`ForceDropOnTeleport` properties and `Use` input.
* Light cookies as drop down.
* Added more NPCs to the entity category.
* Filters can be selected with the eye-dropper.

---

## Installation

### hlvr.fgd
    Navigate to your Half-Life: Alyx hlvr game directory, commonly:
    `steamapps\common\Half-Life Alyx\game\hlvr`
    Overwrite the currently existing `hlvr.fgd` with the file found here of the same name.

### base.fgd
    Navigate to your Half-Life: Alyx core game directory, commonly:
    `steamapps\common\Half-Life Alyx\game\core`
    Overwrite the currently existing `base.fgd` with the file found here of the same name.

You can make a backup of the original files before doing so or get Steam to redownload them by right clicking Half-Life: Alyx within Steam and going to `Properties... > Local Files > Verify integrity of game files...`