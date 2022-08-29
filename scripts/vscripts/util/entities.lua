--[[
    v1.0.0
    https://github.com/FrostSource/hla_extravaganza

    Provides generic function extensions for base entities.
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
---@return EntityHandle
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
---@return EntityHandle
function CBaseEntity:GetFirstChildWithName(name)
    for _, child in ipairs(self:GetChildren()) do
        if child:GetName() == name then
            return child
        end
    end
    return nil
end