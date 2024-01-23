--[[
    v3.0.1
    https://github.com/FrostSource/hla_extravaganza

    The main core script provides useful global functions as well as loading any standard libraries that it can find.

    The two main purposes are:
    
    1. Automatically load libraries to simplify the process for users.
    2. Provide entity class functions to emulate OOP programming.

    Load this script into the global scope using the following line:

    ```lua
    require "core"
    ```

]]

local version = "v3.0.1"

print("Initializing Extravaganza core system ".. version .." ...")

require "util.globals"

-- Base libraries

ifrequire "debug.common"
if not IsVREnabled() then
    ifrequire "debug.novr"
end
ifrequire "util.enums"
ifrequire "util.common"
ifrequire "extensions.string"
ifrequire "extensions.vector"
ifrequire "extensions.entity"
ifrequire "extensions.entities"
ifrequire "extensions.npc"
ifrequire "math.core"
ifrequire "data.queue"
ifrequire "data.stack"
ifrequire "data.inventory"
ifrequire "data.color"

-- Useful extravaganza libraries

ifrequire "player"
ifrequire "class"

ifrequire "input.input"
ifrequire "input.gesture"
ifrequire "input.haptics"

ifrequire "helpers.easyconvars"

ifrequire "gameplay.smooth_speed"

-- Common third-party libraries

ifrequire "wrist_pocket.core"

--#endregion

print("...done")

return version