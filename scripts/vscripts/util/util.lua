--[[
    v2.0.1
    https://github.com/FrostSource/hla_extravaganza

    This file contains utility functions to help reduce repetitive code and add general miscellaneous functionality.

    If not using `vscripts/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "util.util"
    ```
]]

Util = {}

---
---Convert vr_tip_attachment from a game event [1,2] into a hand id [0,1] taking into account left handedness.
---
---@param vr_tip_attachment 1|2
---@return 0|1
function Util.GetHandIdFromTip(vr_tip_attachment)
    local handId = vr_tip_attachment - 1
    if not Convars:GetBool("hlvr_left_hand_primary") then
        handId = 1 - handId
    end
    return handId
end

---
---Estimates the nearest entity `position` with the targetname of `name`
---(or classname `class` if the name is blank).
---
---@param name string
---@param class string
---@param position Vector
---@param radius? number # Default is 128
---@return EntityHandle
function Util.EstimateNearestEntity(name, class, position, radius)
    radius = radius or 128
    local ent
    if name ~= "" then
        local found_ents = Entities:FindAllByName(name)
        -- If only one with this name exists then we can get the exact handle.
        if #found_ents == 1 then
            ent = found_ents[1]
        else
            -- If multiple exist then we need to estimate the entity that was grabbed.
            ent = Entities:FindByNameNearest(name, position, radius)
        end
    else
        -- Entity without name (hopefully doesn't happen) is found by nearest class type.
        ent = Entities:FindByClassnameNearest(class, position, radius)
    end
    return ent
end

---
---Attempt to find a key in `tbl` pointing to `value`.
---
---@param tbl table # The table to search.
---@param value any # The value to search for.
---@return unknown|nil # The key in `tbl` or nil if no `value` was found.
function Util.FindKeyFromValue(tbl, value)
    for key, val in pairs(tbl) do
        if val == value then
            return key
        end
    end
    return nil
end

---
---Attempt to find a key in `tbl` pointing to `value` by recursively searching nested tables.
---
---@param tbl table # The table to search.
---@param value any # The value to search for.
---@param seen? table[] # List of tables that have already been searched.
---@return unknown|nil # The key in `tbl` or nil if no `value` was found.
local function _FindKeyFromValueDeep(tbl, value, seen)
    seen = seen or {}
    for key, val in pairs(tbl) do
        if val == value then
            return key
        elseif type(val) == "table" and not vlua.find(seen, val) then
            seen[#seen+1] = val
            local k = _FindKeyFromValueDeep(val, value, seen)
            if k then return k end
        end
    end
    return nil
end

---
---Attempt to find a key in `tbl` pointing to `value` by recursively searching nested tables.
---
---@param tbl table # The table to search.
---@param value any # The value to search for.
---@return unknown|nil # The key in `tbl` or nil if no `value` was found.
function Util.FindKeyFromValueDeep(tbl, value)
    return _FindKeyFromValueDeep(tbl, value)
end

---Returns the size of any table.
---@param tbl table
---@return integer
function Util.TableSize(tbl)
    local count = 0
    for _, _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

---
---Remove a value from a table, returning it if it exists.
---
---@param tbl table
---@param value any
---@return any
function Util.RemoveFromTable(tbl, value)
    local i = vlua.find(tbl, value)
    if i then
        return table.remove(tbl, i)
    end
    return nil
end

---
---Appends `array2` onto `array1` as a new array.
---Safe extend function alternative to `vlua.extend`.
---
---@param array1 any[]
---@param array2 any[]
function Util.AppendArray(array1, array2)
    array1 = vlua.clone(array1)
    for i = 1, #array2 do
        table.insert(array1, array2[i])
    end
    return array1
end

---
---Delay some code.
---
---@param func function
---@param delay? number
function Util.Delay(func, delay)
    GetListenServerHost():SetContextThink(DoUniqueString("delay"), func, delay or 0)
end

