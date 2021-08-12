
--[[
    This file contains functions to help reduce the amount of repetitive code.

    Load this file at game start using the following line:

    require "util/util_global"

]]

---Returns a zeroed vector.
---@return Vector
function Zero()
    return Vector(0,0,0)
end

---Returns a table to be used with one of the Trace* functions.
---@param startPos Vector
---@param endPos Vector
---@param ignore? CBaseEntity
---@param isCollideable? boolean
---@param min? Vector
---@param max? Vector
---@return table
function TraceTable(startPos, endPos, ignore, isCollideable, min, max)
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

---Prints the given table contents to the console.
---@param t table
function PrintTable(t)
    local pair
    if #t > 0 then
        pair = ipairs(t)
    else
        pair = pairs(t)
    end
    for k,v in pair do
        print(k, v)
    end
end
