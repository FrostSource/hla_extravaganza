--[[
    v1.0.0
    https://github.com/FrostSource/hla_extravaganza

    Extensions for the `Entities` class.

    If not using `vscripts/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "extensions.entities"
    ```
]]

---
---Gets an array of every entity that currently exists.
---
---@return EntityHandle[]
function Entities:All()
    local ents = {}
    local e = Entities:First()
    while e ~= nil do
        table.insert(ents, e)
        e = Entities:Next(e)
    end
    return ents
end

---
---Gets a random entity in the map.
---
---@return EntityHandle
function Entities:Random()
    local all = Entities:All()
    return all[RandomInt(1, #all)]
end
