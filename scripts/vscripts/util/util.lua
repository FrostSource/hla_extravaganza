
--[[
    This file contains utility functions to help reduce repetitive code.

    Load this file at game start using the following line:

        require "util.util"

    -

    Function catagories are split into nested tables within the main Util table.

    You can create an alias for a catagory to make referencing easier by assigning it to
    a variable within your script:

        local vmath = Util.Math
        local zero = vmath.Zero()

]]

Util = Util or {}

---Returns a table to be used with one of the Trace* functions.
---@param startPos Vector
---@param endPos Vector
---@param ignore? CBaseEntity
---@param isCollideable? boolean
---@param min? Vector
---@param max? Vector
---@return table
Util.TraceTable = function(startPos, endPos, ignore, isCollideable, min, max)
    local t
    if isCollideable then
        t = {
            startPos = startPos,
            endPos = endPos,
            ent = ignore,
        }
        if min then t.mins = min end
        if max then t.maxs = min end
    else
        t = {
            startPos = startPos,
            endPos = endPos,
            ignore = ignore,
            min = min or Vector(0,0,0),
            max = max or Vector(0,0,0),
        }
    end
    return t
end

---Converts vr_tip_attachment from a game event [1,2] into a hand id [0,1] taking into account left handedness.
---@param vr_tip_attachment "1"|"2"
---@return "0"|"1"
Util.GetHandIdFromTip = function(vr_tip_attachment)
    local handId = vr_tip_attachment - 1
    if not Convars:GetBool("hlvr_left_hand_primary") then
        handId = 1 - handId
    end
    return handId
end

--[[
    Math function.
]]

Util.Math = Util.Math or {}

---Returns a zeroed vector.
---@return Vector
Util.Math.Zero = function()
    return Vector(0,0,0)
end
