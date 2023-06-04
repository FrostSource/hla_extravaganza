--[[
    v1.2.0
    https://github.com/FrostSource/hla_extravaganza

    Provides base entity extension methods.

    If not using `vscripts/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "extensions.entity"
    ```
]]

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
function CBaseEntity:SetAngle(qangle)
    self:SetAngles(qangle.x, qangle.y, qangle.z)
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
    local size = self:GetSize()
    return size.x * size.y * size.z
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

