--[[
    v1.1.0
    https://github.com/FrostSource/hla_extravaganza

    Provides Vector class extension methods.

    If not using `vscripts/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "extensions.vector"
    ```
]]

local version = "v1.1.0"

---@class Vector
local meta = getmetatable(Vector())

local zero = Vector(0, 0, 0)
-- local up = Vector(0, 0, 1)
-- local right = Vector(0, 1, 0)

---
---Calculates the perpendicular vector to the current vector.
---
---@return Vector # The perpendicular vector.
function meta:Perpendicular()
    if self.y == 0 and self.z == 0 then
        if self.x == 0 then
            return Vector()
        else
            -- If the vector is parallel to the YZ plane, calculate the cross product with the Y-axis.
            return self:Cross(Vector(0, 1, 0))
        end
    end
    -- If the vector is not parallel to the YZ plane, calculate the cross product with the X-axis.
    return self:Cross(Vector(1, 0, 0))
end

---
---Checks if the current vector is perpendicular to the given vector.
---
---@param vector Vector # The vector to compare with.
---@return boolean # True if the vectors are perpendicular, false otherwise.
function meta:IsPerpendicular(vector)
    return self:Dot(vector) == 0
end

---
---Checks if the current vector is parallel to the given vector.
---
---@param vector Vector # The vector to compare with.
---@return boolean # True if the vectors are parallel, false otherwise.
function meta:IsParallel(vector)
    -- Treat zero vectors as parallel to any vector
    if self == zero or vector == zero then
        return true
    end

    return self:Normalized() == vector:Normalized() or self:Normalized() == -vector:Normalized()
end

---
---Spherical linear interpolation between the calling vector and the target vector over t = [0, 1].
---
---@param target Vector # The target vector to interpolate towards.
---@param t number # The interpolation factor, ranging from 0 to 1.
---@return Vector # The resulting vector after spherical linear interpolation.
function meta:Slerp(target, t)
    local dot = self:Dot(target)
    dot = math.max(-1, math.min(1, dot))

    local theta = math.acos(dot) * t
    local relative = target - (self * dot)
    relative = relative:Normalized()

    local a = self * math.cos(theta)
    local b = relative * math.sin(theta)

    return a + b
end

return version