--[[
    v1.0.0
    https://github.com/FrostSource/hla_extravaganza
]]

---------------------
-- Global functions
---------------------

---Get the file name of the current script without folders or extension. E.g. `util.util`
---@param sep string? # Separator character, default is '.'
---@param level (integer|function)? # Function level, [View documents](command:extension.lua.doc?["en-us/51/manual.html/pdf-debug.getinfo"])
---@return string
function GetScriptFile(sep, level)
    sep = sep or "."
    local sys_sep = package.config:sub(1,1)
    local src = debug.getinfo(level or 2,'S').source
    src = src:match('^.+vscripts[/\\](.+).lua$')--[[@as string]]
    local split = src:split(sys_sep)
    src = table.concat(split, sep)
    return src
end

---Get if the given `handle` value is an entity, regardless of if it's still alive.
---@param handle EntityHandle|any
---@param checkValidity boolean? # Optionally check validity with IsValidEntity.
---@return boolean
function IsEntity(handle, checkValidity)
    return (type(handle) == "table" and handle.__self) and (not checkValidity or IsValidEntity(handle))
end

---Add an output to a given entity `handle`.
---@param handle EntityHandle|string # The entity to add the `output` to.
---@param output string # The output name to add.
---@param target EntityHandle|string # The entity the output should target, either handle or targetname.
---@param input string # The input name on `target`.
---@param parameter string? # The parameter override for `input`.
---@param delay number? # Delay for the output in seconds.
---@param activator EntityHandle? # Activator for the output.
---@param caller EntityHandle? # Caller for the output.
---@param fireOnce boolean? # If the output should only fire once.
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

---Checks if the module/script exists.
---@param name string?
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
                -- package.preload[name] = loader
                return true
            end
        end
        return false
    end
end

---Loads the given module, returns any value returned by the given module(true when nil).
---Then runs the given callback function.
---If the module fails to load then the callback is not executed and no error is thrown.
---@param modname string
---@param callback fun(mod_result: unknown)?
---@return unknown
---@diagnostic disable-next-line: lowercase-global
function ifrequire(modname, callback)
    --TODO: Consider using module_exists
    local success, result = pcall(require, modname)
    if success and callback then
        callback(result)
        return result
    end
    return nil
end

---Execute a script file. Included in the current scope by default.
---@param scriptFileName string
---@param scope ScriptScope?
---@return boolean
function IncludeScript(scriptFileName, scope)
    return DoIncludeScript(scriptFileName, scope or getfenv(2))
end

---Gets if the game was started in VR mode.
---@return boolean
function IsVREnabled()
    return GlobalSys:CommandLineCheck('-vr')
end

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


---------------
-- Extensions
---------------
-- Consider separate extension script

---Find an entity within the same prefab as another entity.
---Will have issues in nested prefabs.
---@param entity EntityHandle
---@param name string
---@return EntityHandle?
function Entities:FindInPrefab(entity, name)
    local myname = entity:GetName()
    for _,ent in ipairs(Entities:FindAllByName('*' .. name)) do
        local prefab_part = ent:GetName():sub(1, #ent:GetName() - #name)
        if prefab_part == myname:sub(1, #prefab_part) then
            return ent
        end
    end
    return nil
end

---Find an entity within the same prefab as this entity.
---Will have issues in nested prefabs.
---@param name string
---@return EntityHandle?
function CEntityInstance:FindInPrefab(name)
    return Entities:FindInPrefab(self, name)
end


-------------------
-- Custom classes
-------------------

---@type table<string, table>
EntityClassNameMap = {}

-- look up for `k' in list of tables `plist'
local function search (k, plist)
    -- print("\nCPhysicsProp", CPhysicsProp)
    for i=1, #plist do
      local v = plist[i][k]     -- try `i'-th superclass
        -- print("current table", plist[i])
      if not v and type(plist[i].__index) == "table" then
        -- print("HERE",plist[i].__index)
        v = plist[i].__index[k]
      end
      if v then return v end
    end
  end

---@generic T
---@param name `T` # Internal class name
---@param ... string|table
---@return T # Base class
---@return T # Self instance
---@return table # Super class
function entity(name, ...)

    local inherits = {...}

    -- Name is optional and might be inherit script
    if type(name) == "table" or module_exists(name) then
        table.insert(inherits, 1, name)
        name = nil
    end
    if name == nil then
        name = DoUniqueString("CustomEntityClass")
    end

    -- Execute any script inherits to get the class table
    for index, inherit in ipairs(inherits) do
        if type(inherit) == "string" then
            -- string is name
            if EntityClassNameMap[inherit] then
                inherits[index] = EntityClassNameMap[inherit]
            -- string is script
            else
                local base = require(inherit)
                inherits[index] = base
            end
        end
    end
    ---@cast inherits table[]

    -- fenv is the private script scope
    local fenv = getfenv(2)
    ---@type EntityClass?
    local self = fenv.thisEntity

    -- if self == nil then
    --     error("`entity` function must be called from a script attached to an entity!")
    -- end

    -- Try to retrieve cached class
    local base = EntityClassNameMap[name]
    if not base then
        base = {
            name = name,
            script_file = GetScriptFile(nil, 3),
            inherits = inherits
        }
        -- Meta table to search all inherits
        setmetatable(base, {
            __index = function(t,k)
                -- prints("Trying access",k,"in",t,"from base metatable __index")
                return search(k, base.inherits)
            end
        })
        -- 
        base.__index = base
        -- function(t,k)
        --     prints("Trying access",k,"in",t,"from base.__index")
        --     -- print("but first showing all inherits")
        --     -- Debug.PrintTable(base.inherits)
        --     -- if base[k] then return base[k] end
        --     -- return search(k, base.inherits)
        -- end
        EntityClassNameMap[name] = base
    end

    -- Add base as middleman metatable if script is attached to entity
    local super = inherits[1]
    if self then
        -- super = getmetatable(self)
        -- if inherits[1] then
        --     super = inherits[1]
        --     setmetatable(base, {__index = super})
        -- else
        --     setmetatable(base, super)
        -- end
        -- setmetatable(self, {__index = base})

        -- local valve_meta = getmetatable(self)
        -- -- Debug.PrintTable(valve_meta)
        -- print(valve_meta.__index.DisableMotion)
        -- print(valve_meta.__index.GetName)
        -- print(getmetatable(valve_meta))
        -- table.insert(base.inherits, valve_meta)
        -- local meta = getmetatable(self)
        -- print(meta)
        -- print(getmetatable(meta.__index))
        -- while meta do
        --     print(meta)
        --     meta = getmetatable(meta)
        -- end

        -- Add this entity's metatable as an inherit
        local valve_meta = getmetatable(self)
        table.insert(base.inherits, valve_meta)

        setmetatable(self, base)

        fenv.Activate = function(activateType)
            if type(self.Ready) == "function" then
                self.Ready(self--[[@as EntityClass]])
            end
        end

        -- TODO: Replace with pre defined function
        self.Save = function(s)
            print("Saving...")
        end
    end

    return base, self, super
end


-------------
-- Includes
-------------

ifrequire 'debug.core'
ifrequire 'util.util'
ifrequire 'util.enums'
ifrequire 'extensions.entity'
ifrequire 'extensions.string'
ifrequire 'math.core'

---Add a function to the global scope with alternate casing styles.
---Makes a function easier to call from Hammer through I/O.
---@param func function # The function to sanitize.
---@param name? string # Optionally the name of the function for faster processing.
---@param scope? table # Optionally the explicit scope to put the sanitized functions in.
Expose = function(func, name, scope)
    --Consider extracting `SanitizeFunctionForHammer` directly to core
    Warning("Cannot expose "..tostring(func).." because Util class is not defined!")
end
if Util then
    Expose = Util.SanitizeFunctionForHammer
end

ifrequire 'storage'
ifrequire 'input'
ifrequire 'player'