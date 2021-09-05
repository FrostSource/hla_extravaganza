# Scripts

> This collection includes stand alone scripts and scripts used in conjunction with prefabs and other assets. See the individual README.md files for information on how the script is used. If no README is present it is likely used by another asset and shouldn't be used on its own unless you understand the contents.

> If a script does not have an accompanying README but you think it *should*, please [open up a new issue](https://github.com/FrostSource/hla_extravaganza/issues/new) with a reference/link to the script file with a short explaination why it should.

---

## vlua_globals.lua

This file helps intellisense in editors like Visual Studio Code by introducing definitions of all known VLua functions into the global scope. It is purely for helping with the coding process and does not introduce or modify any functionality in-game.

I recommend using [Visual Studio Code](https://code.visualstudio.com/) with this Lua extension:
https://marketplace.visualstudio.com/items?itemName=sumneko.lua

Place this file in the top level of your scripting folder, e.g.
    
    game\hlvr_addons\my_addon\scripts\
    
or

    game\hlvr_addons\my_addon\scripts\vscripts\

As long as the editor knows about this file it should assume its contents belong in the global scope, even though this file will never be executed.

Hook snippets are included in the [.vscode/vlua_snippets.code-snippets](.vscode/vlua_snippets.code-snippets) file to help speed up the process.
Start typing "hook" or the name of the function for the options to appear.

*More information is included in the header of the script itself.*