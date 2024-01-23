> Last Updated 2024-01-23

## Index
1. [easyconvars.lua](#easyconvarslua)

---

# easyconvars.lua

> v1.0.0

Allows for quick creation of convars which support persistence saving, checking GlobalSys for default values, and callbacks on value change. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "util.util"
```


### Usage 


EasyConvars are useful when you need a convar that performs actions when the value is changed or needs to be saved and automatically saved on game load. 

For this example we will create a convar that draws a debug line to the nearest resin when turned on. 



```lua
EasyConvars:Register("example_debug_resin", "0", function (val)
    -- Turn the string value into a boolean
    val = truthy(val)

    local player = Entities:GetLocalPlayer()

    if not player then
        -- Player wasn't found so return false to override the user's value
        -- false automatically converts to "0"
        return false
    end

    -- Perform an action based on the value the user gave
    if val == true then
        player:SetThink(function()
            local resin = Entities:FindByClassnameNearest("item_hlvr_crafting_currency_small", player:GetOrigin(), 1000)
            if resin then
                DebugDrawLine(player:GetOrigin(), resin:GetOrigin(), 255,255,255, true, 1)
            end
            return 1
        end, "example_debug_resin", 0)
    else
        player:StopThink("example_debug_resin")
    end

    -- No need to return a value at the end, the user's input is used
end)
```


After the convar is registered, it will be accessible in the console like any other convar. It will behave like a regular convar even though internally it is registered as a command. If the user accesses the convar without any value it will display the current value in the console. 

If we want the convar to be saved when it is changed we can call another method right after defining it: 



```lua
EasyConvars:SetPersistent("example_debug_resin", true)
```


Sometimes we need to know the value of our convar in code so the standard 'get' methods found in the Convars class are also available in EasyConvars: 



```lua
-- Assuming the convar was set to 1 in the console.
val = EasyConvars:GetString("example_debug_resin") -- "1"
val = EasyConvars:GetBool("example_debug_resin") -- true
val = EasyConvars:GetFloat("example_debug_resin") -- 1
val = EasyConvars:GetInt("example_debug_resin") -- 1
```


You MUST use the EasyConvars methods for retrieving the values as they are registered as console commands instead of normal convars. 

If you don't need a callback and just want the saving feature you can simply set the callback to `nil` in the `Register` method, or use the `RegisterConvar` method instead. 



```lua
EasyConvars:RegisterConvar("example_debug_resin", "0")
EasyConvars:SetPersistent("example_debug_resin", true)
```


## Functions

<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`EasyConvars:Register(name, default, func, helpText, flags)`</td><td>Create a convar with a callback function.</td></tr><tr><td>

`EasyConvars:Save(name)`</td><td>Manually saves the current value of the convar with a given name. This is done automatically when the value is changed if SetPersistent is set to true.</td></tr><tr><td>

`EasyConvars:Load(name)`</td><td>Manually loads the saved value of the convar with a given name. This is done automatically when the player spawns for any previously saved convar.</td></tr><tr><td>

`EasyConvars:SetPersistent(name, persistent)`</td><td>Sets the convar as persistent. It will be saved to the player when changed and load its previous state when the map starts.  Convars with previously saved data will have persistence automatically turned on when loaded.</td></tr><tr><td>

`EasyConvars:RegisterConvar(name, defaultValue, helpText, flags)`</td><td>Calls the register function using the same syntax as the built-in convar library, for easy converting.</td></tr><tr><td>

`EasyConvars:RegisterCommand(name, callback, helpText, flags)`</td><td>Calls the register function using the same syntax as the built-in convar library, for easy converting.</td></tr><tr><td>

`EasyConvars:GetStr(name)`</td><td>Returns the convar as a string.</td></tr><tr><td>

`EasyConvars:GetBool(name)`</td><td>Returns the convar as a boolean.</td></tr><tr><td>

`EasyConvars:GetFloat(name)`</td><td>Returns the convar as a float.</td></tr><tr><td>

`EasyConvars:GetInt(name)`</td><td>Returns the convar as an integer.</td></tr><tr><td>

`EasyConvars:SetStr(name, value)`</td><td>Sets the value of the convar to a string and calls any associated callback.</td></tr><tr><td>

`EasyConvars:SetBool(name, value)`</td><td>Sets the value of the convar to a boolean and calls any associated callback.</td></tr><tr><td>

`EasyConvars:SetFloat(name, value)`</td><td>Sets the value of the convar to a float and calls any associated callback.</td></tr><tr><td>

`EasyConvars:SetInt(name, value)`</td><td>Sets the value of the convar to an integer and calls any associated callback.</td></tr></table>



