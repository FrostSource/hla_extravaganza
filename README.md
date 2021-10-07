A collection of scripts and resources to improve functionality of Half-Life: Alyx for mappers.

Still in early development.

# Downloads

Navigate to the release section to download zips of the latest assets: https://github.com/FrostSource/hla_extravaganza/releases

A google drive is also updated for those who have trouble with GitHub, you can also download individual assets this way: https://drive.google.com/drive/folders/1RJi9jYKfPpHuwCR8c3NqfYy5A1A9WkgA

## Installation

All files and folders are structured in a way to allow direct copying into your content folder, with 2 exceptions (see [scripts](#scripts) and [fgd](#fgd) below).

Simply drag the contents of the release zips into your content folder, e.g.

`steamapps\common\Half-Life Alyx\content\hlvr_addons\my_addon\`

### Scripts

Script files are consumed by the game engine directly so are placed in the `game` folder instead of the `content` folder, e.g.

`steamapps\common\Half-Life Alyx\game\hlvr_addons\my_addon\`

You will have two subfolders in your addons `game` folder, `scripts` and `scripts\vscripts`:

`steamapps\common\Half-Life Alyx\game\hlvr_addons\my_addon\scripts\`
`steamapps\common\Half-Life Alyx\game\hlvr_addons\my_addon\scripts\vscripts\`

The `vscripts` folder is where all Lua files will be loaded from by the game engine.

### FGD

FGD files are loaded from the main game directly and are not associated with specific addons. See the [FGD README](fgd/README.md) for installation instructions.

# Contributing Assets

See the [contributing guide](guides/contributing/README.md) for a detailed explanation about adding your own assets.

If you can't follow the guide or have an aversion to git, you can [join the discord](https://discord.gg/yTQhGeKxSK) and show us the asset you would like to contribute, one of our contributors is likely to add it.

# Full Project Downloads

Links to Half-Life: Alyx addons that are free to download and learn from.

| Title | Author(s) | Link |
| ----- | --------- | ---- |
| Vinny Almost Misses Christmas | FrostSource | https://github.com/FrostSource/vinny_christmas |
| Arena #VMLOOPED | FrostSource | https://github.com/FrostSource/hla-arena |
| Tower: Agency Classic | FrostSource | https://github.com/FrostSource/toweragency |
| Tower: Agency Revamp | FrostSource <br> ihonnyboy | https://github.com/FrostSource/toweragency/tree/redesign |
| His Mercy | FrostSource | https://github.com/FrostSource/his_mercy