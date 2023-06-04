--[[
    v1.2.1
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

---
---Find an entity within the same prefab as another entity.
---
---Will have issues in nested prefabs.
---
---@param entity EntityHandle
---@param name string
---@return EntityHandle?
---@return string # Prefab part of the name.
function Entities:FindInPrefab(entity, name)
    local myname = entity:GetName()
    for _,ent in ipairs(Entities:FindAllByName('*' .. name)) do
        local prefab_part = ent:GetName():sub(1, #ent:GetName() - #name)
        if prefab_part == myname:sub(1, #prefab_part) then
            return ent, prefab_part
        end
    end
    return nil, ""
end

---
---Find an entity within the same prefab as this entity.
---
---Will have issues in nested prefabs.
---
---@param name string
---@return EntityHandle?
---@return string # Prefab part of the name.
function CEntityInstance:FindInPrefab(name)
    return Entities:FindInPrefab(self, name)
end
