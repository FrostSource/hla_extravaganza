--[[
    v3.0.0
    https://github.com/FrostSource/hla_extravaganza

    The main core script provides useful global functions as well as loading any standard libraries that it can find.

    The two main purposes are:
    
    1. Automatically load libraries to simplify the process for users.
    2. Provide entity class functions to emulate OOP programming.

    Load this script into the global scope using the following line:

    ```lua
    require "core"
    ```

]]

local version = "v3.0.0"

print("Initializing Extravaganza core system ".. version .." ...")

-- These are expected by core
require 'util.util'
require 'extensions.string'

---------------------
-- Global functions
--#region
---------------------

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
    ---@TODO: User tables might have __self as key, is there anything unique we can look for?
    return (type(handle) == "table" and handle.__self) and (not checkValidity or IsValidEntity(handle))
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
-- Old name for Expose
--SanitizeFunctionForHammer = Expose

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
---Returns a random value from an array.
---
---@generic T
---@param array T[] # Array to get a value from.
---@param min? integer # Optional minimum bound.
---@param max? integer # Optional maximum bound.
---@return T one # The random value.
---@return integer two # The random index.
function RandomFromArray(array, min, max)
    local i = RandomInt(min or 1, max or #array)
    return array[i], i
end

---
---Returns a random key/value pair from a unordered table.
---
---@param tbl table # Table to get a random pair from.
---@return any key # Random key selected.
---@return any value # Value linked to the random key.
function RandomFromTable(tbl)
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
---Shuffles a given array.
---
---@source https://stackoverflow.com/a/68486276
---
---@param t any[]
function ShuffleArray(t)
    for i = #t, 2, -1 do
        local j = RandomInt(1, i)
        t[i], t[j] = t[j], t[i]
    end
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
        parameters.ignoreent = {parameters.ignore}
    else
        parameters.ignoreent = parameters.ignore
        parameters.ignore = nil
    end
    if type(parameters.ignoreclass) == "string" then
        ---@diagnostic disable-next-line: assign-type-mismatch
        parameters.ignoreclass = {parameters.ignoreclass}
    end
    if type(parameters.ignorename) == "string" then
        ---@diagnostic disable-next-line: assign-type-mismatch
        parameters.ignorename = {parameters.ignorename}
    end
    parameters.traces = 1
    parameters.timeout = parameters.timeout or math.huge

    local result = TraceLine(parameters)
    -- print(parameters.hit, parameters.enthit)
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

---@luadoc-ignore
---@diagnostic disable-next-line:lowercase-global
function printmeta(ent)
    local meta = getmetatable(ent)
    vlua.tableadd(DeepCopyTable(ent), meta or {})
    if meta then
        printmeta(getmetatable(meta))
    end
end


--#endregion

-------------
-- Includes
--#region
-------------

-- Base libraries

ifrequire 'debug.core'
ifrequire 'util.enums'
ifrequire 'extensions.vector'
ifrequire 'extensions.entity'
ifrequire 'extensions.entities'
ifrequire 'extensions.npc'
ifrequire 'math.core'
ifrequire 'data.queue'
ifrequire 'data.stack'
ifrequire 'data.inventory'

-- Useful extravaganza libraries

ifrequire 'input'
ifrequire 'gesture'
ifrequire 'player'
ifrequire 'class'

-- Common third-party libraries

ifrequire 'wrist_pocket.core'

--#endregion

print("...done")

return version