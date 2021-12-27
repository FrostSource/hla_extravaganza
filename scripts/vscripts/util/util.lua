--[[
    This file contains utility functions to help reduce repetitive code
    and add general miscellaneous functionality.

    Load this file at game start using the following line:

        require "util.util"

    -

    Function catagories are split into nested tables within the main 'util' table.

    You can create an alias for a catagory to make referencing easier by assigning it to
    a variable within your script:

        local vmath = Util.Math

]]
---@diagnostic disable: lowercase-global
util = {}

---Returns a table to be used with one of the Trace* functions.
---
---**Use vlua_snippets trace snippets instead.**
---@param startPos Vector
---@param endPos Vector
---@param ignore? CBaseEntity
---@param isCollideable? boolean
---@param min? Vector
---@param max? Vector
---@deprecated
---@return table
function util.TraceTable(startPos, endPos, ignore, isCollideable, min, max)
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
function util.GetHandIdFromTip(vr_tip_attachment)
    local handId = vr_tip_attachment - 1
    if not Convars:GetBool("hlvr_left_hand_primary") then
        handId = 1 - handId
    end
    return handId
end

---Estimates the nearest entity `position` with the targetname of `name`
---(or classname `class` if the name is blank).
---@param name string
---@param class string
---@param position CBaseEntity
---@return EntityHandle
function util.EstimateNearestEntity(name, class, position)
    local ent
    if name ~= "" then
        local found_ents = Entities:FindAllByName(name)
        -- If only one with this name exists then we can get the exact handle.
        if #found_ents == 1 then
            ent = found_ents[1]
        else
            -- If multiple exist then we need to estimate the entity that was grabbed.
            ent = Entities:FindByNameNearest(name, position, 128)
        end
    else
        -- Entity without name (hopefully doesn't happen) is found by nearest class type.
        ent = Entities:FindByClassnameNearest(class, position, 128)
    end
    return ent
end

---Prints the keys/values of a table and any tested tables.
---
---This is different from `DeepPrintTable` in that it will not print members of entity handles.
---@param tbl any
---@param prefix any
function util.PrintTable(tbl, prefix)
    prefix = prefix or ""
    print(prefix.."{")
    for key, value in pairs(tbl) do
        print( string.format( "\t%s%-32s %s", prefix, key, "= " .. (type(value) == "string" and ("\"" .. tostring(value) .. "\"") or tostring(value)) .. " ("..type(value)..")" ) )
        if type(value)=="table" then
            util.PrintTable(value, prefix.."\t")
        end
    end
    print(prefix.."}")
end


--------------------
-- Math functions --
--------------------

util.math = {}
