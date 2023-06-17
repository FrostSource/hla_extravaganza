--[[
    v1.3.0
    https://github.com/FrostSource/hla_extravaganza

    Extensions for the `Entities` class.

    If not using `vscripts/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "extensions.entities"
    ```
]]

local version = "v1.3.0"

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





function Entities:FindAllInCone(origin, direction, maxDistance, maxAngle)
    local cosMaxAngle = math.cos(math.rad(maxAngle))
    local entitiesInSphere = Entities:FindAllInSphere(origin, maxDistance)

    -- Filter the entities based on whether they fall within the cone
    local entitiesInCone = {}
    for i = 1, #entitiesInSphere do
        local entity = entitiesInSphere[i]
        local directionToEntity = (entity:GetAbsOrigin() - origin):Normalized()
        local dotProduct = direction:Dot(directionToEntity)
        -- If the dot product is greater than or equal to the cosine of the max angle, the entity is within the cone
        if dotProduct >= cosMaxAngle then
            table.insert(entitiesInCone, entity)
        end
    end

    return entitiesInCone
end


function Entities:FindAllInConeGenerous(origin, direction, maxDistance, maxAngle)
    local cosMaxAngle = math.cos(math.rad(maxAngle))
    local entitiesInSphere = Entities:FindAllInSphere(origin, maxDistance)

    -- Filter the entities based on whether they fall within the cone
    local entitiesInCone = {}
    for i = 1, #entitiesInSphere do
        local entity = entitiesInSphere[i]
        local directionToEntity = (entity:GetAbsOrigin() - origin):Normalized()
        local dotProduct = direction:Dot(directionToEntity)
        -- If the dot product is greater than or equal to the cosine of the max angle, the entity is within the cone
        if dotProduct >= cosMaxAngle then
            table.insert(entitiesInCone, entity)
        else
            -- Check bounding corners too
            local corners = entity:GetBoundingCorners()
            for j = 1, #corners do
                directionToEntity = (corners[j] - origin):Normalized()
                dotProduct = direction:Dot(directionToEntity)
                if dotProduct >= cosMaxAngle then
                    table.insert(entitiesInCone, entity)
                    break
                end
            end
        end
    end

    return entitiesInCone
end

return version