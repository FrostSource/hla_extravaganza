--[[
    v1.1.0
    https://github.com/FrostSource/hla_extravaganza

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

---------------------
-- Global functions
---------------------

---Get the file name of the current script. E.g. `util.util`
---@param sep? string # Separator character
---@return string
function GetScriptFile(sep)
    sep = sep or "."
    local sys_sep = package.config:sub(1,1)
    local src = debug.getinfo(2,'S').source
    src = src:match('^.+vscripts[/\\](.+).lua$')
    local split = util.SplitString(src, sys_sep)
    src = table.concat(split, sep)
    return src
end


----------------------
-- Utility functions
-- (should some of these be global?)
----------------------


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
---@param radius? number # Default is 128
---@return EntityHandle
function util.EstimateNearestEntity(name, class, position, radius)
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

---Prints the keys/values of a table and any tested tables.
---
---This is different from `DeepPrintTable` in that it will not print members of entity handles.
---@param tbl table
---@param prefix? string
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

---Get the first child in an entity's hierarchy with a given classname.
---@param handle EntityHandle
---@param classname string
---@return EntityHandle
function util.GetFirstChildWithClassname(handle, classname)
    for _, child in ipairs(handle:GetChildren()) do
        if child:GetClassname() == classname then
            return child
        end
        local c = util:GetFirstChildWithClassname(child)
        if c then
            return c
        end
    end
    return nil
end
CBaseEntity.GetFirstChildWithClassname = util.GetFirstChildWithClassname

---Get the first child in an entity's hierarchy with a given target name.
---@param handle EntityHandle
---@param name string
---@return EntityHandle
function util.GetFirstChildWithName(handle, name)
    for _, child in ipairs(handle:GetChildren()) do
        if child:GetName() == name then
            return child
        end
        local c = util:GetFirstChildWithClassname(child)
        if c then
            return c
        end
    end
    return nil
end
CBaseEntity.GetFirstChildWithName = util.GetFirstChildWithName

---Attempt to find a key in `tbl` pointing to `value`.
---@param tbl table # The table to search.
---@param value any # The value to search for.
---@return string # Returns nil if no key found.
function util.FindKeyFromValue(tbl, value)
    for key, val in pairs(tbl) do
        if val == value then
            return key
        end
    end
    return nil
end

---Attempt to find a key in `tbl` pointing to `value` by recursively searching nested tables.
---@param tbl table # The table to search.
---@param value any # The value to search for.
---@param seen? table[] # List of tables that have already been searched.
---@return string # Returns nil if no key found.
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

---Attempt to find a key in `tbl` pointing to `value` by recursively searching nested tables.
---@param tbl table # The table to search.
---@param value any # The value to search for.
---@return string # Returns nil if no key found.
function util.FindKeyFromValueDeep(tbl, value)
    return _FindKeyFromValueDeep(tbl, value)
end

---Add a function to the global scope with alternate casing styles.
---Makes a function easier to call from Hammer through I/O.
---@param func function # The function to sanitize.
---@param name? string # Optionally the name of the function for faster processing. Is required if using a local function.
---@param scope? table # Optionally the explicit scope to put the sanitized functions in.
function util.SanitizeFunctionForHammer(func, name, scope)
    -- if name is nil then find the name
    local fenv = getfenv(func)
    if name == "" or name == nil then
        name = util.FindKeyFromValueDeep(fenv, func)
        -- if name is still after search environment, search locals
        if name == nil then
            -- locals get put in global scope
            fenv = _G
            local i = 1
            while true do
                name,val = debug.getlocal(2,i)
                if name == nil or val == func then break end
                i = i + 1
            end
            -- if name is still nil then function doesn't exist yet
            if name == nil then
                Warning("Trying to sanitize function ["..tostring(func).."] which doesn't exist in environment!\n")
                return
            end
        end
    end
    fenv = scope or fenv
    print("Sanitizing function '"..name.."' for Hammer in scope ["..tostring(fenv).."]")
    fenv[name] = func
    fenv[name:lower()] = func
    fenv[name:upper()] = func
    fenv[name:sub(1,1):upper()..name:sub(2)] = func
end

---Returns the size of any table.
---@param tbl table
---@return integer
function util.TableSize(tbl)
    local count = 0
    for _, _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

---Remove a value from a table, returning it if it exists.
---@param tbl table
---@param value any
---@return any
function util.RemoveFromTable(tbl, value)
    local i = vlua.find(tbl, value)
    if i then
        return table.remove(tbl, i)
    end
    return nil
end

---Split an input string using a separator string.
---
---Found at https://stackoverflow.com/a/7615129
---@param inputstr string # String to split.
---@param sep string # String to split by.
---@return string[]
function util.SplitString(inputstr, sep)
    if sep == nil then
        sep = '%s'
    end
    local t = {}
    for str in string.gmatch(inputstr, '([^'..sep..']+)') do
        table.insert(t, str)
    end
    return t
end


--------------------
-- Math functions --
--------------------

util.math = {}
