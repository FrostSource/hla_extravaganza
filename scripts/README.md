# Scripts

> This collection includes stand alone scripts and scripts used in conjunction with prefabs and other assets. See the individual script header for information about how the script is used.

---

## vlua_globals.lua

### What is it?

This file is for use with [Visual Studio Code](https://code.visualstudio.com/) and the [Lua Language Server](https://marketplace.visualstudio.com/items?itemName=sumneko.lua), improving intellisense by declaring all known Lua functions specific to Half-Life: Alyx into the global scope. It is purely for helping with the coding process and does not introduce or modify any functionality in-game.

### Why use it?

If you've written a script in VS Code for Alyx you might be familiar with warnings about unknown names and types.

![](../.images/vlua_globals_no_help.png)

`vlua_globals.lua` fixes these issues and provides full code completion for known functions and methods, including descriptions and type hinting. This dramatically improves the coding process allowing you to focus on writing the script instead of looking up function definitions or double checking if a warning is legitimate.

![](../.images/vlua_globals_completion.png)
![](../.images/vlua_globals_type.gif)

### Installation

Copy the `vlua_globals.lua` file anywhere within your VS Code workspace. It is often placed in the root of your scripts folder, e.g.

    game\hlvr_addons\my_addon\scripts\

As long as the editor knows about this file it should assume its contents belong in the global scope, even though this file will never be executed. If you are using Git and are having issues with `vlua_globals.lua` not being recognized, make sure it is **not** excluded via .gitignore.

*More information is included in the header of the script itself.*