--[[
    v2.2.0
    https://github.com/FrostSource/hla_extravaganza

    Provides base entity extension methods.

    If not using `vscripts/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "extensions.entity"
    ```
]]

local version = "v2.2.0"

---
---Get the top level entities parented to this entity. Not children of children.
---
---@return table
function CBaseEntity:GetTopChildren()
    local children = {}
    for _, child in ipairs(self:GetChildren()) do
        if child:GetMoveParent() == self then
            children[#children+1] = child
        end
    end
    return children
end

---
---Send an input to this entity.
---
---@param action string # Input name.
---@param value? any # Parameter override for the input.
---@param delay? number # Delay in seconds.
---@param activator? EntityHandle
---@param caller? EntityHandle
function CBaseEntity:EntFire(action, value, delay, activator, caller)
    DoEntFireByInstanceHandle(self, action, value and tostring(value) or "", delay or 0, activator or nil, caller or nil)
end

---
---Get the first child in this entity's hierarchy with a given classname.
---
---@param classname string # Classname to find.
---@return EntityHandle|nil # The child found.
function CBaseEntity:GetFirstChildWithClassname(classname)
    for _, child in ipairs(self:GetChildren()) do
        if child:GetClassname() == classname then
            return child
        end
    end
    return nil
end

---
---Get the first child in this entity's hierarchy with a given target name.
---
---@param name string # Targetname to find.
---@return EntityHandle|nil # The child found.
function CBaseEntity:GetFirstChildWithName(name)
    for _, child in ipairs(self:GetChildren()) do
        if child:GetName() == name then
            return child
        end
    end
    return nil
end

---
---Set entity pitch, yaw, roll from a `QAngle`.
---
---@param qangle QAngle
function CBaseEntity:SetQAngle(qangle)
    self:SetAngles(qangle.x, qangle.y, qangle.z)
end

---
---Set entity pitch, yaw or roll. Supply `nil` for any parameter to leave it unchanged.
---
---@param pitch number|nil
---@param yaw number|nil
---@param roll number|nil
function CBaseEntity:SetAngle(pitch, yaw, roll)
    local angles = self:GetAngles()
    self:SetAngles(pitch or angles.x, yaw or angles.y, roll or angles.z)
end

---
---Get the bounding size of the entity.
---
---@return Vector
function CBaseEntity:GetSize()
    return self:GetBoundingMaxs() - self:GetBoundingMins()
end

---
---Get the biggest bounding box axis of the entity.
---This will be `size.x`, `size.y` or `size.z`.
---
---@return number
function CBaseEntity:GetBiggestBounding()
    local size = self:GetSize()
    return math.max(size.x, size.y, size.z)
end

---
---Get the radius of the entity bounding box. This is half the size of the sphere.
---
---@return number
function CBaseEntity:GetRadius()
    return self:GetSize():Length() * 0.5
end

---
---Get the volume of the entity bounds in inches cubed.
---
---@return number
function CBaseEntity:GetVolume()
    local size = self:GetSize() * self:GetAbsScale()
    return size.x * size.y * size.z
end

---
---Get each corner of the entity's bounding box.
---
---@param rotated? boolean # If the corners should be rotated with the entity angle.
---@return Vector[]
function CBaseEntity:GetBoundingCorners(rotated)
    local bounds = self:GetBounds()
    local origin = self:GetOrigin()
    local corners = {
        origin + bounds.Mins * self:GetAbsScale(),
        origin + bounds.Maxs * self:GetAbsScale(),
        origin + Vector(bounds.Mins.x, bounds.Mins.y, bounds.Maxs.z) * self:GetAbsScale(),
        origin + Vector(bounds.Maxs.x, bounds.Mins.y, bounds.Mins.z) * self:GetAbsScale(),
        origin + Vector(bounds.Mins.x, bounds.Maxs.y, bounds.Mins.z) * self:GetAbsScale(),
        origin + Vector(bounds.Maxs.x, bounds.Maxs.y, bounds.Mins.z) * self:GetAbsScale(),
        origin + Vector(bounds.Maxs.x, bounds.Mins.y, bounds.Maxs.z) * self:GetAbsScale(),
        origin + Vector(bounds.Mins.x, bounds.Maxs.y, bounds.Maxs.z) * self:GetAbsScale(),
    }

    if rotated then
        local angle = self:GetAngles()
        for k, v in pairs(corners) do
            corners[k] = RotatePosition(origin, angle, v)
        end
    end

    return corners
end

---
---Check if entity is within the given worldspace bounds.
---
---@param mins Vector # Worldspace minimum vector for the bounds.
---@param maxs Vector # Worldspace minimum vector for the bounds.
---@param checkEntityBounds? boolean # If true the entity bounding box will be used for the check instead of its origin.
---@return boolean # True if the entity is within the bounds, false otherwise.
function CBaseEntity:IsWithinBounds(mins, maxs, checkEntityBounds)
    local selfMins, selfMaxs
    if checkEntityBounds then
        selfMins = self:GetOrigin() + self:GetBoundingMins()
        selfMaxs = self:GetOrigin() + self:GetBoundingMaxs()
    else
        selfMins = self:GetOrigin()
        selfMaxs = selfMins
    end
    if selfMins.x <= maxs.x and selfMaxs.x >= mins.x
    and selfMins.y <= maxs.y and selfMaxs.y >= mins.y
    and selfMins.z <= maxs.z and selfMaxs.z >= mins.z
    then
        return true
    end
    return false
end

---
---Send the `DisablePickup` input to the entity.
---
function CBaseEntity:DisablePickup()
    DoEntFireByInstanceHandle(self, "DisablePickup", "", 0, self, self)
end

---
---Send the `EnablePickup` input to the entity.
---
function CBaseEntity:EnablePickup()
    DoEntFireByInstanceHandle(self, "EnablePickup", "", 0, self, self)
end

---
---Delay some code using this entity.
---
---@param func function
---@param delay number?
function CBaseEntity:Delay(func, delay)
    self:SetContextThink(DoUniqueString("delay"), function() func() end, delay or 0)
end

---
---Get all parents in the hierarchy upwards.
---
---@return EntityHandle[]
function CBaseEntity:GetParents()
    local parents = {}
    local parent = self:GetMoveParent()
    while parent ~= nil do
        parents[#parents+1] = parent
        parent = parent:GetMoveParent()
    end
    return parents
end

---
---Set if the prop is allowed to be dropped. Only works for physics based props.
---
---@param enabled boolean # True if the prop can't be dropped, false for can be dropped.
function CBaseEntity:DoNotDrop(enabled)
    if enabled then
        self:Attribute_SetIntValue("DoNotDrop", 1)
    else
        self:DeleteAttribute("DoNotDrop")
    end
end

---
---Get all criteria as a table.
---
---@return CriteriaTable
function CBaseEntity:GetCriteria()
    local c = {}
    self:GatherCriteria(c)
    return c
end

---
---Get all entities which are owned by this entity
---
---**Note:** This searches all entities in the map and should be used sparingly.
---@return EntityHandle[]
function CBaseEntity:GetOwnedEntities()
    local ents = {}
    local ent = Entities:First()
    while ent ~= nil do
        if ent ~= self and ent:GetOwner() == self then
            table.insert(ents, ent)
        end
        ent = Entities:Next(ent)
    end
    return ents
end

---Set the alpha modulation of this entity plus any children.
---@param alpha integer
function CBaseModelEntity:SetRenderAlphaAll(alpha)
    for _, child in ipairs(self:GetChildren()) do
        child:SetRenderAlpha(alpha)
    end
    self:SetRenderAlpha(alpha)
end

return version