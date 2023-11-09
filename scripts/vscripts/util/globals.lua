--[[
    v1.0.0
    https://github.com/FrostSource/hla_extravaganza

    Provides common global functions used throughout extravaganza libraries.

    If not using `vscripts/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "util.globals"
    ```
]]

-- These are expected by globals
require 'util.common'

---
---Get the file name of the current script without folders or extension. E.g. `util.util`
---
---@param sep?  string # Separator character, default is '.'
---@param level? (integer|function)? # Function level, [View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-debug.getinfo"])
---@return string
function GetScriptFile(sep, level)
    sep = sep or "."
    local sys_sep = package.config:sub(1,1)
    local src = debug.getinfo(level or 2,'S').source
    src = src:match('^.+vscripts[/\\](.+).lua$')

    local split = {}
    for part in src:gmatch('([^'..sys_sep..']+)') do
        table.insert(split, part)
    end

    src = table.concat(split, sep)
    return src
end

---
---Get if the given `handle` value is an entity, regardless of if it's still alive.
---
---A common usage is replacing the often used entity check:
---
---    if entity ~= nil and IsValidEntity(entity) then
---
---With:
---
---    if IsEntity(entity, true) then
---
---@param handle EntityHandle|any
---@param checkValidity? boolean # Optionally check validity with IsValidEntity.
---@return boolean
function IsEntity(handle, checkValidity)
    return (type(handle) == "table" and handle.__self and type(handle.__self) == "userdata") and (not checkValidity or IsValidEntity(handle))
end

---
---Add an output to a given entity `handle`.
---
---@param handle     EntityHandle|string # The entity to add the `output` to.
---@param output     string # The output name to add.
---@param target     EntityHandle|string # The entity the output should target, either handle or targetname.
---@param input      string # The input name on `target`.
---@param parameter? string # The parameter override for `input`.
---@param delay?     number # Delay for the output in seconds.
---@param activator? EntityHandle # Activator for the output.
---@param caller?    EntityHandle # Caller for the output.
---@param fireOnce?  boolean # If the output should only fire once.
function AddOutput(handle, output, target, input, parameter, delay, activator, caller, fireOnce)
    if IsEntity(target) then target = target:GetName() end
    parameter = parameter or ""
    delay = delay or 0
    local output_str = output..">"..target..">"..input..">"..parameter..">"..delay..">"..(fireOnce and 1 or -1)
    if type(handle) == "string" then
        DoEntFire(handle, "AddOutput", output_str, 0, activator or nil, caller or nil)
    else
        DoEntFireByInstanceHandle(handle, "AddOutput", output_str, 0, activator or nil, caller or nil)
    end
end
CBaseEntity.AddOutput = AddOutput

---
---Checks if the module/script exists.
---
---@param name? string
---@return boolean
---@diagnostic disable-next-line: lowercase-global
function module_exists(name)
    if name == nil then return false end
    if package.loaded[name] then
        return true
    else
        for _, searcher in ipairs(package.loaders) do
            local loader = searcher(name)
            if type(loader) == 'function' then
                return true
            end
        end
        return false
    end
end

---
---Loads the given module, returns any value returned by the given module(`true` when module returns nothing).
---
---Then runs the given callback function.
---
---If the module fails to load then the callback is not executed and no error is thrown.
---
---@param modname string
---@param callback fun(mod_result: unknown)?
---@return unknown
---@diagnostic disable-next-line: lowercase-global
function ifrequire(modname, callback)
    ---@TODO: Consider using module_exists
    local success, result = pcall(require, modname)
    if success and callback then
        callback(result)
        return result
    end
    return nil
end

---
---Execute a script file. Included in the current scope by default.
---
---@param scriptFileName string
---@param scope?         ScriptScope
---@return boolean
function IncludeScript(scriptFileName, scope)
    return DoIncludeScript(scriptFileName, scope or getfenv(2))
end

---
---Gets if the game was started in VR mode.
---
---@return boolean
function IsVREnabled()
    return GlobalSys:CommandLineCheck('-vr')
end

---
---Prints all arguments with spaces between instead of tabs.
---
---@param ... any
---@diagnostic disable-next-line: lowercase-global
function prints(...)
    local args = {...}
    local argsn = #args
    local t = ""
    for i,v in ipairs(args) do
        t = t .. tostring(v)
        if i < argsn then
            t = t .. " "
        end
    end
    print(t)
end

---
---Prints all arguments on a new line instead of tabs.
---
---@param ... any
---@diagnostic disable-next-line: lowercase-global
function printn(...)
    local args = {...}
    for _,v in ipairs(args) do
        print(v)
    end
end

---
---Prints all arguments if convar "developer" is greater than 0.
---
---@param ... any
---@diagnostic disable-next-line: lowercase-global
function devprint(...)
    if Convars:GetInt("developer") > 0 then
        print(...)
    end
end

---
---Prints all arguments on a new line instead of tabs if convar "developer" is greater than 0.
---
---@param ... any
---@diagnostic disable-next-line: lowercase-global
function devprints(...)
    if Convars:GetInt("developer") > 0 then
        prints(...)
    end
end

---
---Prints all arguments with spaces between instead of tabs if convar "developer" is greater than 0.
---
---@param ... any
---@diagnostic disable-next-line: lowercase-global
function devprintn(...)
    if Convars:GetInt("developer") > 0 then
        printn(...)
    end
end

---
---Prints all arguments if convar "developer" is greater than 1.
---
---@param ... any
---@diagnostic disable-next-line: lowercase-global
function devprint2(...)
    if Convars:GetInt("developer") > 1 then
        print(...)
    end
end

---
---Prints all arguments on a new line instead of tabs if convar "developer" is greater than 1.
---
---@param ... any
---@diagnostic disable-next-line: lowercase-global
function devprints2(...)
    if Convars:GetInt("developer") > 1 then
        prints(...)
    end
end

---
---Prints all arguments with spaces between instead of tabs if convar "developer" is greater than 1.
---
---@param ... any
---@diagnostic disable-next-line: lowercase-global
function devprintn2(...)
    if Convars:GetInt("developer") > 1 then
        printn(...)
    end
end

---
---Add a function to the calling entity's script scope with alternate casing.
---
---Makes a function easier to call from Hammer through I/O.
---
---E.g.
---
---    local function TriggerRelay(io)
---        DoEntFire("my_relay", "Trigger", "", 0, io.activator, io.caller)
---    end
---    Expose(TriggerRelay)
---    -- Or with alternate name
---    Expose(TriggerRelay, "RelayInput")
---
---@param func function # The function to expose.
---@param name? string # Optionally the name of the function for faster processing.
---@param scope? table # Optionally the explicit scope to put the exposed function in.
function Expose(func, name, scope)
    local fenv = getfenv(func)
    -- if name is empty then find the name
    if name == "" or name == nil then
        name = vlua.find(fenv, func)
        -- if name is still empty after searching environment, search locals
        if name == nil then
            local i = 1
            while true do
                local val
                name, val = debug.getlocal(2,i)
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
    if Convars:GetInt("developer") > 0 then
        devprint2("Sanitizing function '"..name.."' for Hammer in scope ["..tostring(fenv).."]")
    end
    fenv[name] = func
    fenv[name:lower()] = func
    fenv[name:upper()] = func
    fenv[name:sub(1,1):upper()..name:sub(2)] = func
end

local base_vector = Vector()
local vector_meta = getmetatable(base_vector)

---
---Get if a value is a `Vector`
---
---@param value any
---@return boolean
function IsVector(value)
    return getmetatable(value) == vector_meta
end

local base_qangle = QAngle()
local qangle_meta = getmetatable(base_qangle)

---
---Get if a value is a `QAngle`
---
---@param value any
---@return boolean
function IsQAngle(value)
    return getmetatable(value) == qangle_meta
end

---
---Copy all keys from `tbl` and any nested tables into a brand new table and return it.
---This is a good way to get a unique reference with matching data.
---
---Any functions and userdata will be copied by reference, except for:
---`Vector`,
---`QAngle`
---
---@param tbl table
---@return table
function DeepCopyTable(tbl)
    -- print("Deep copy inside", tbl)
    local t = {}
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            if IsEntity(value) then
                t[key] = value
            else
                -- print("Delving deeper into", key, value)
                t[key] = DeepCopyTable(value)
            end
        elseif IsVector(value) then
            t[key] = Vector(value.x, value.y, value.z)
        elseif IsQAngle(value) then
            t[key] = QAngle(value.x, value.y, value.z)
        else
            t[key] = value
        end
    end
    return t
end

---
---Searches for `value` in `tbl` and sets the associated key to `nil`, returning the key if found.
---
---If working with arrays you should use `ArrayRemove` instead.
---
---@param tbl table
---@param value any
---@return any
function TableRemove(tbl, value)
    local k = vlua.find(tbl, value)
    if k then
        tbl[k] = nil
        return k
    end
    return nil
end

---
---Returns a random key/value pair from a unordered table.
---
---@param tbl table # Table to get a random pair from.
---@return any key # Random key selected.
---@return any value # Value linked to the random key.
function TableRandom(tbl)
    local count = 0
    local selectedKey

    for key in pairs(tbl) do
        count = count + 1

        -- Randomly select a key with 1/count probability
        if RandomFloat(0, 1) < 1 / count then
            selectedKey = key
        end
    end

    return selectedKey, tbl[selectedKey]
end

---
---Returns a random value from an array.
---
---@generic T
---@param array T[] # Array to get a value from.
---@param min? integer # Optional minimum bound.
---@param max? integer # Optional maximum bound.
---@return T one # The random value.
---@return integer two # The random index.
function ArrayRandom(array, min, max)
    local i = RandomInt(min or 1, max or #array)
    return array[i], i
end

---
---Shuffles a given array in-place.
---
---@source https://stackoverflow.com/a/68486276
---
---@param array any[]
function ArrayShuffle(array)
    for i = #array, 2, -1 do
        local j = RandomInt(1, i)
        array[i], array[j] = array[j], array[i]
    end
end

---
---Remove an item from an array at a given position.
---
---This is significantly faster than `table.remove`.
---
---@generic T
---@param array T # The array to remove from.
---@param pos integer # Position to remove at.
---@return T # The same array passed in.
function ArrayRemove(array, pos)
    local j, n = 1, #array

    for i = 1,n do
        if i == pos then
            -- Move i's kept value to j's position, if it's not already there.
            if i ~= j then
                array[j] = array[i]
                array[i] = nil
            end
            j = j + 1 -- Increment position of where we'll place the next kept value.
        else
            array[i] = nil
        end
    end

    return array
end

---
---Appends `array2` onto `array1` as a new array.
---
---Safe extend function alternative to `vlua.extend`, neither input arrays are modified.
---
---@generic T1
---@generic T2
---@param array1 T1[] # Base array
---@param array2 T2[] # Array which will be appended onto the base array.
---@return T1[]|T2[] # The new appended array.
function ArrayAppend(array1, array2)
    array1 = vlua.clone(array1)
    for _, v in ipairs(array2) do
        table.insert(array1, v)
    end
    return array1
end




---@class TraceTableLineExt : TraceTableLine
---@field ignore (EntityHandle|EntityHandle[])? # Entity or array of entities to ignore.
---@field ignoreclass (string|string[])? # Class or array of classes to ignore.
---@field ignorename (string|string[])? # Name or array of names to ignore.
---@field timeout integer? # Maxmimum number of traces before returning regardless of parameters.
---@field traces integer # Number of traces done.
---@field dontignore EntityHandle # A single entity to always hit, ignoring if it exists in `ignore`.

---
---Does a raytrace along a line with extended parameters.
---You ignore multiple entities as well as classes and names.
---Because the trace has to be redone multiple times, a `timeout` parameter can be defined to cap the number of traces.
---
---@param parameters TraceTableLineExt
---@return boolean
function TraceLineExt(parameters)
    if IsEntity(parameters.ignore) then
        ---@diagnostic disable-next-line: inject-field
        parameters.ignoreent = {parameters.ignore}
    else
        ---@diagnostic disable-next-line: inject-field
        parameters.ignoreent = parameters.ignore
        parameters.ignore = nil
    end
    if type(parameters.ignoreclass) == "string" then
        parameters.ignoreclass = {parameters.ignoreclass}
    end
    if type(parameters.ignorename) == "string" then
        parameters.ignorename = {parameters.ignorename}
    end
    parameters.traces = 1
    parameters.timeout = parameters.timeout or math.huge

    local result = TraceLine(parameters)
    while parameters.traces < parameters.timeout and parameters.hit and parameters.enthit ~= parameters.dontignore and
    (
        vlua.find(parameters.ignoreent, parameters.enthit)
        or vlua.find(parameters.ignoreclass, parameters.enthit:GetClassname())
        or vlua.find(parameters.ignorename, parameters.enthit:GetName())
    )
    do
        --Debug
        -- local reason = "Unknown reason"
        -- if vlua.find(parameters.ignoreent, parameters.enthit) then
        --     reason = "Entity handle is ignored"
        -- elseif vlua.find(parameters.ignoreclass, parameters.enthit:GetClassname()) then
        --     reason = "Entity class is ignored"
        -- elseif vlua.find(parameters.ignorename, parameters.enthit:GetName()) then
        --     reason = "Entity name is ignored"
        -- end
        -- print("TraceLineExt hit: "..parameters.enthit:GetClassname()..", "..parameters.enthit:GetName().." - Ignoring because: ".. reason .."\n")
        --EndDebug
        parameters.traces = parameters.traces + 1
        parameters.ignore = parameters.enthit
        parameters.enthit = nil
        parameters.startpos = parameters.pos
        result = TraceLine(parameters)
    end

    return result
end

---
---Does a raytrace along a line until it hits or the world or reaches the end of the line.
---
---@param parameters TraceTableLine
function TraceLineWorld(parameters)
    local result = TraceLine(parameters)
    while parameters.hit and parameters.enthit:GetClassname() ~= "worldent" do
        parameters.ignore = parameters.enthit
        parameters.enthit = nil
        parameters.startpos = parameters.pos
        result = TraceLine(parameters)
    end
    return result
end

---
---Get if an entity is the world entity.
---
---@param entity EntityHandle
---@return boolean
function IsWorld(entity)
    return IsEntity(entity) and entity:GetClassname() == "worldent"
end

---
---Get the world entity.
---
---@return EntityHandle
function GetWorld()
    return Entities:FindByClassname(nil, "worldent")
end

---
---Get if a table has a key (this essentially the same as tbl[key] ~= nil).
---
---@param tbl table
---@param key any
---@return boolean
---@luadoc-ignore
---@diagnostic disable-next-line:lowercase-global
function haskey(tbl, key)
    for k, _ in pairs(tbl) do
        if k == key then return true end
    end
    return false
end

---
---Check if a value is truthy or falsy.
---
--- **falsy == `nil`|`false`|`0`|`""`|`{}`**
---
---@param value any # The value to be checked.
---@return boolean # Returns true if the value is truthy, false otherwise.
---@diagnostic disable-next-line:lowercase-global
function truthy(value)
    return not (value == nil or value == false or value == 0 or value == "" or (type(value) == "table" and next(value) == nil))
end

---
---Search an entity for a key using a search pattern. E.g. "getclass" will find "GetClassname"
---
---Works with `class.lua` EntityClass entities.
---
---@param entity EntityHandle|EntityClass
---@param searchPattern string
---@return string? key # The full name of the first key matching `searchPattern`.
---@return any? value # The value of the key found.
function SearchEntity(entity, searchPattern)
    searchPattern = searchPattern:lower()

    local function searchTable(tbl, pattern)
        for key, value in pairs(tbl) do
            if debug then  print("", key, value) end
            local lkey = key:lower()
            if not lkey:startswith("set") then
                if string.find(lkey, pattern) then
                    if debug then print(key, value) end
                    return key, value
                end
            end
        end
    end

    if rawget(entity, "__inherits") then
        local inherits = getinherits(entity)
        for _, tbl in ipairs(inherits) do
            local key, value = searchTable(tbl, searchPattern)
            if key or value then
                return key, value
            end
        end

        -- Set up the valve meta to be searched since inherits failed to find pattern
        entity = getvalvemeta(entity).__index
    end

    while type(entity) == "table" do
        local key, value = searchTable(entity, searchPattern)
        if key or value then
            return key, value
        end
        entity = getmetatable(entity).__index
    end

    return nil, nil
end
