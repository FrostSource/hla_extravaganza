--[[
    v2.1.0
    https://github.com/FrostSource/hla_extravaganza

    This file contains utility functions to help reduce repetitive code and add general miscellaneous functionality.

    If not using `vscripts/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "util.util"
    ```
]]

Util = {}
Util.version = "v2.1.0"

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

---Append any number of arrays onto `array` and return as a new array.
---Safe extend function alternative to `vlua.extend`.
---@param array any[]
---@param ... any[]
function Util.AppendArrays(array, ...)
    local arg = {...}
    local n = #arg
    array = vlua.clone(array)
    for _, arr in ipairs(arg) do
        for i = 1, #arr do
            table.insert(array, arr[i])
        end
    end
    return array
end

---
---Delay some code.
---
---@param func function
---@param delay? number
function Util.Delay(func, delay)
    GetListenServerHost():SetContextThink(DoUniqueString("delay"), func, delay or 0)
end

---
---Get a new `QAngle` from a `Vector`.
---This simply transfers the raw values from one to the other.
---
---@param vec Vector
---@return QAngle
function Util.QAngleFromVector(vec)
    return QAngle(vec.x, vec.y, vec.z)
end

---Create a constraint between two entity handles.
---@param entity1 EntityHandle # First entity to attach.
---@param entity2 EntityHandle|nil # Second entity to attach. Set nil to attach to world.
---@param class? string # Class of constraint, default is `phys_constraint`.
---@param properties? table # Key/value property table.
---@return EntityHandle
function Util.CreateConstraint(entity1, entity2, class, properties)
    -- Cache original names
    local name1 = entity1:GetName()
    local name2 = entity2 and entity2:GetName() or ""

    -- Assign unique names so constraint can find them on spawn
    local uname1 = DoUniqueString("")
    entity1:SetEntityName(uname1)
    local uname2 = entity2 and DoUniqueString("") or ""
    if entity2 then entity2:SetEntityName(uname2) end

    properties = vlua.tableadd({attach1 = uname1, attach2 = uname2}, properties or {})
    local constraint = SpawnEntityFromTableSynchronous(class or "phys_constraint", properties)

    -- Restore original names now that constraint knows their handles
    entity1:SetEntityName(name1)
    if entity2 then entity2:SetEntityName(name2) end
    return constraint
end

---Choose and return a random argument.
---@generic T
---@param ... T
---@return T
function Util.Choose(...)
    local args = {...}
    local numArgs = #args
    if numArgs == 0 then
        return nil
    elseif numArgs == 1 then
        return args[1]
    else
        return args[RandomInt(1, numArgs)]
    end
end

---Turns a string of up to three numbers into a vector.
---@param str string # Should have a format of "x y z"
---@return Vector
function Util.VectorFromString(str)
    if type(str) ~= "string" then
        return Vector()
    end
    local x, y, z = str:match("(%d+)[^%d]+(%d*)[^%d]+(%d*)")
    return Vector(tonumber(x), tonumber(y), tonumber(z))
end