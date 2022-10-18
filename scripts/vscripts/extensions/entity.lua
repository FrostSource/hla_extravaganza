--[[
    v1.1.0
    https://github.com/FrostSource/hla_extravaganza

    Provides base entity extension methods.
]]

---Get the top level entities parented to this entity. Not children of children.
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

---Send an input to this entity.
---@param action string # Input name.
---@param value? string # Parameter override for the input.
---@param delay? number # Delay in seconds.
---@param activator? EntityHandle
---@param caller? EntityHandle
function CBaseEntity:EntFire(action, value, delay, activator, caller)
    DoEntFireByInstanceHandle(self, action, value or "", delay or 0, activator or nil, caller or nil)
end

---Get the first child in this entity's hierarchy with a given classname.
---@param classname string
---@return EntityHandle|nil
function CBaseEntity:GetFirstChildWithClassname(classname)
    for _, child in ipairs(self:GetChildren()) do
        if child:GetClassname() == classname then
            return child
        end
    end
    return nil
end

---Get the first child in this entity's hierarchy with a given target name.
---@param name string
---@return EntityHandle|nil
function CBaseEntity:GetFirstChildWithName(name)
    for _, child in ipairs(self:GetChildren()) do
        if child:GetName() == name then
            return child
        end
    end
    return nil
end

---Set entity pitch, yaw, roll from a `QAngle`. If parented, this is set relative to the parents local space.
---@param qangle any
function CBaseEntity:SetAngle(qangle)
    self:SetAngles(qangle.x, qangle.y, qangle.z)
end

---Gets the biggest bounding box axis of the entity.
---@return number
function CBaseEntity:GetBiggestBounding()
    return #(self:GetBoundingMaxs() - self:GetBoundingMins())
end

---Sends the `DisablePickup` input to the entity.
function CBaseEntity:DisablePickup()
    DoEntFireByInstanceHandle(self, "DisablePickup", "", 0, self, self)
end
---Sends the `EnablePickup` input to the entity.
function CBaseEntity:EnablePickup()
    DoEntFireByInstanceHandle(self, "EnablePickup", "", 0, self, self)
end

---Delay some code using this entity.
---@param func function
---@param delay number?
function CBaseEntity:Delay(func, delay)
    self:SetContextThink(DoUniqueString("delay"), function() func() end, delay or 0)
end

---Gets all parents in the hierarchy upwards.
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

