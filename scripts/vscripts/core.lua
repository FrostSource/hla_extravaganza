--[[
    v1.0.3
    https://github.com/FrostSource/hla_extravaganza
]]

---------------------
-- Global functions
---------------------

---
---Get the file name of the current script without folders or extension. E.g. `util.util`
---
---@param sep?  string # Separator character, default is '.'
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

---
---Get if the given `handle` value is an entity, regardless of if it's still alive.
---
---@param handle EntityHandle|any
---@param checkValidity? boolean # Optionally check validity with IsValidEntity.
---@return boolean
function IsEntity(handle, checkValidity)
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
                -- package.preload[name] = loader
                return true
            end
        end
        return false
    end
end

---
---Loads the given module, returns any value returned by the given module(`true` when `nil`).
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
    --TODO: Consider using module_exists
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


---------------
-- Extensions
---------------
-- Consider separate extension script

---
---Find an entity within the same prefab as another entity.
---
---Will have issues in nested prefabs.
---
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

---
---Find an entity within the same prefab as this entity.
---
---Will have issues in nested prefabs.
---
---@param name string
---@return EntityHandle?
function CEntityInstance:FindInPrefab(name)
    return Entities:FindInPrefab(self, name)
end

local base_vector = Vector()
---
---Get if a value is a `Vector`
---
---@param value any
---@return boolean
function IsVector(value)
    return type(value) == "userdata" and value.__index==base_vector.__index
end

local base_qangle = QAngle()
---
---Get if a value is a `QAngle`
---
---@param value any
---@return boolean
function IsQAngle(value)
    return type(value) == "userdata" and value.__index==base_qangle.__index
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
            -- print("Delving deeper into", key, value)
            t[key] = DeepCopyTable(value)
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


-------------------
-- Custom classes
-------------------

---@type table<string, table>
EntityClassNameMap = {}

-- look up for `k' in list of tables `plist'
local function search(k, plist)
    for i = 1, #plist do
        local v = plist[i][k]
        if not v and type(plist[i].__index) == "table" then
            v = plist[i].__index[k]
        end
        if v then return v end
    end
end

local function save_entity_data(self)
    for key, value in pairs(self) do
        if not key:startswith("__") and type(value) ~= "function" then
            -- print("Saving "..key, value)
            Storage.Save(self, key, value)
        end
    end
end

local function load_entity_data(self)
    for key, value in pairs(self) do
        if not key:startswith("__") and type(value) ~= "function" then
            -- print("Loading "..key, "default "..tostring(value))
            self[key] = Storage.Load(self, key, value)
            -- print("Loaded "..key, self[key])
        end
    end
end

---Class that inherits all entity classes. Mostly used when creating entity classes.
---`EntityHandle` should still be used when handling and passing entity types.
---@class EntityClass : EntityClassBase,CBaseEntity,CEntityInstance,CBaseModelEntity,CBasePlayer,CHL2_Player,CBaseAnimating,CBaseFlex,CBaseCombatCharacter,CBodyComponent,CAI_BaseNPC,CBaseTrigger,CEnvEntityMaker,CInfoWorldLayer,CLogicRelay,CMarkupVolumeTagged,CEnvProjectedTexture,CPhysicsProp,CSceneEntity,CPointClientUIWorldPanel,CPointTemplate,CPointWorldText,CPropHMDAvatar,CPropVRHand
local EntityClass = {}

---@class EntityClassBase
local EntityClassBase = {}
---Save all entity data
function EntityClassBase:Save()
end
---Called automatically if defined
---@param loaded boolean
function EntityClassBase:OnReady(loaded)
end
---Called automatically if defined
---@param spawnkeys CScriptKeyValues
function EntityClassBase:OnSpawn(spawnkeys)
end
---Called automatically if defined
function EntityClassBase:Think()
end
---Called automatically if defined
function EntityClassBase:ResumeThink()
end
---Called automatically if defined
function EntityClassBase:PauseThink()
end
---@type boolean
EntityClassBase.Initiated = false
---@type boolean
EntityClassBase.IsThinking = false

---
---Creates a new entity class.
---
---If this is called in an entity attached script then the entity automatically
---inherits the class and the class inherits the entity's metatable.
---
---The class is only created once so this can be called in entity attached scripts
---multiple times and all subsequent calls will return the already created class.
---
---@generic      T
---@param name? `T` # Internal class name
---@param ...    string|table # Any inherit classes or scripts.
---@return T # Base class, the newly created class.
---@return T # Self instance, the entity inheriting `base`.
---@return table # Super class, the first inheritance of `base`.
---@diagnostic disable-next-line: lowercase-global
function entity(name, ...)

    local inherits = {...}

    -- Check if name is actually an inherit (class name was omitted)
    if type(name) ~= "string" and (type(name) == "table" or module_exists(name)) then
        table.insert(inherits, 1, name)
        name = nil
    end
    if name == nil then
        name = DoUniqueString("CustomEntityClass")
    end

    -- Execute any script inherits to get the class table
    for index, inherit in ipairs(inherits) do
        if type(inherit) == "string" then
            if EntityClassNameMap[inherit] then
                -- string is defined name
                inherits[index] = EntityClassNameMap[inherit]
            else
                -- string is script
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
            __name = name,
            __script_file = GetScriptFile(nil, 3),
            __inherits = inherits
        }
        -- Meta table to search all inherits
        setmetatable(base, {
            __index = function(t,k)
                -- prints("Trying access",k,"in",t,"from base metatable __index")
                return search(k, base.__inherits)
            end
        })
        -- Base will search itself and then its metatable
        base.__index = base
        EntityClassNameMap[name] = base
    end

    -- Add base as middleman metatable if script is attached to entity
    local super = inherits[1]
    if self then
        -- Add this entity's metatable as an inherit
        local valve_meta = getmetatable(self)
        table.insert(base.__inherits, valve_meta)

        setmetatable(self, base)

        -- Special functions --

        fenv.Spawn = function(spawnkeys)
            if type(self.OnSpawn) == "function" then
                self:OnSpawn(spawnkeys)
            end
        end

        fenv.Activate = function(activateType)

            -- Copy base reference data into self
            -- TODO: Copy inherited references too
            for key, value in pairs(base) do
                if not key:startswith("__") and type(value) == "table" then
                    -- print("Deep copying", key, value)
                    self[key] = DeepCopyTable(value)
                end
            end

            if activateType == 2 then
                -- Load all saved entity data
                load_entity_data(self)
            end

            -- Fire custom ready function
            if type(self.OnReady) == "function" then
                self:OnReady(activateType == 2)
            end

            if self.IsThinking then
                self:ResumeThink()
            end

            self.Initiated = true
            self:Save()

        end

        function self:ResumeThink()
            if type(self.Think) == "function" then
                self:SetContextThink("__EntityThink", function() return self:Think() end, 0)
                self.IsThinking = true
                self:Save()
            else
                Warning("Entity does not have self:Think function defined!")
            end
        end

        function self:PauseThink()
            self:SetContextThink("__EntityThink", nil, 0)
            self.IsThinking = false
            self:Save()
        end

        -- Define function to save all entity data
        self.Save = save_entity_data

        self.Initiated = false
        self.IsThinking = false
    end

    return base, self, super
end


-------------
-- Includes
-------------

-- Base libraries

ifrequire 'debug.core'
ifrequire 'util.util'
ifrequire 'util.enums'
ifrequire 'extensions.entity'
ifrequire 'extensions.string'
ifrequire 'math.core'
ifrequire 'data.queue'
ifrequire 'data.stack'
ifrequire 'data.inventory'

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

ifrequire 'wrist_pocket.core'