--[[
    v2.0.1

    Helps with saving/loading values for persistency between game sessions.
    Values are saved into the entity running this script. If the entity
    is killed the values cannot be retrieved during that game session.

    To use this script globally you must require it:

    require "util.storage"

    --

    Functions are accessed through the global 'Storage' table.
    When using dot notation (Storage.SaveNumber) you must provide the entity handle to save on.
    When using colon notation (Storage:SaveNumber) the script will find the best handle to save on (usually the player).

    Examples of storing and retrieving the following local values that might be defined
    at the top of the file:

    local origin = thisEntity:GetOrigin()
    local hp     = thisEntity:GetHealth()
    local name   = thisEntity:GetName()

    Saving the values:

    Storage:SaveVector("origin", origin)
    Storage:SaveNumber("hp", hp)
    Storage:SaveString("name", name)

    Loading the values:

    origin = Storage:LoadVector("origin")
    hp     = Storage:LoadNumber("hp")
    name   = Storage:LoadString("name")

    This script also provides functions Storage.Save/Storage.Load for general purpose
    type inference storage. It is still recommended that you use the explicit type
    functions to keep code easily understandable, but it can help with prototyping:

    Storage:Save("origin", origin)
    Storage:Save("hp", hp)
    Storage:Save("name", name)

    origin = Storage:Load("origin", origin)
    hp     = Storage:Load("hp", hp)
    name   = Storage:Load("name", name)

    --

    Entity versions of the functions exist to make saving to a specific entity easier:

    thisEntity:SaveNumber("hp", thisEntity:GetHealth())
    thisEntity:SetHealth(thisEntity:LoadNumber("hp"))

    --

    Please be aware that there seems to be a hard limit on 63 characters for strings.
    Try to keep your names and values as short as possible or break them up into more values.
]]

local debug_allowed = false
---Print a warning message if in developer mode.
---@param msg any
local function Warn(msg)
    -- if debug_allowed and Convars:GetBool( 'developer' ) then
    if debug_allowed then
        Warning(msg)
    end
end

---Resolve a given handle.
---@param handle EntityHandle
---@return EntityHandle
local function resolveHandle(handle)
    -- Keep given handle if valid entity
    if IsValidEntity(handle) then
        return handle
    end

    ---- Otherwise check if the calling scope is an entity and use that
    -----@diagnostic disable-next-line: deprecated
    --local fenv = getfenv(3)
    --if fenv.thisEntity then
    --    return fenv.thisEntity
    --end

    -- Otherwise save on player
    local player = GetListenServerHost()
    if not player then
        Warn("Trying to save a global value before player has spawned!\n")
        return nil
    end
    return player

    -- if handle == Storage then
    --     return thisEntity or GetListenServerHost()
    -- end
    -- return handle or thisEntity or GetListenServerHost()
end


local separator = "::"

if thisEntity then
    print("Storage is being included in an entity context...")

    require "util.storage"
else
    print("Storage is being required in a global context...")
    Storage = {}

    ------------
    -- SAVING --
    ------------

    ---Save a string. Strings seem to be limited to 63 characters!
    ---@param handle CBaseEntity # Entity to save on.
    ---@param name string # Name to save as.
    ---@param value string # String to save.
    function Storage.SaveString(handle, name, value)
        --TODO: Break up strings longer than 63 chars. Also update table saving with this.
        handle = resolveHandle(handle)
        if not handle then
            Warn("Invalid save handle ("..tostring(handle)..")!\n")
            return
        end
        handle:SetContext(name, value, 0)
        handle:SetContext(name..separator.."type", "string", 0)
    end

    ---Save a number.
    ---@param handle CBaseEntity # Entity to save on.
    ---@param name string # Name to save as.
    ---@param value number # Number to save.
    function Storage.SaveNumber(handle, name, value)
        handle = resolveHandle(handle)
        if not handle then
            Warn("Invalid save handle ("..tostring(handle)..")!\n")
            return
        end
        handle:SetContextNum(name, value, 0)
        handle:SetContext(name..separator.."type", "number", 0)
    end

    ---Save a boolean.
    ---@param handle CBaseEntity # Entity to save on.
    ---@param name string # Name to save as.
    ---@param bool boolean # Boolean to save.
    function Storage.SaveBoolean(handle, name, bool)
        handle = resolveHandle(handle)
        handle:SetContextNum(name, bool and 1 or 0, 0)
        handle:SetContext(name..separator.."type", "boolean", 0)
    end

    ---Save a Vector.
    ---@param handle CBaseEntity # Entity to save on.
    ---@param name string # Name to save as.
    ---@param vector Vector # Vector to save.
    function Storage.SaveVector(handle, name, vector)
        handle = resolveHandle(handle)
        handle:SetContext(name..separator.."type", "vector", 0)
        Storage.SaveNumber(handle, name .. ".x", vector.x)
        Storage.SaveNumber(handle, name .. ".y", vector.y)
        Storage.SaveNumber(handle, name .. ".z", vector.z)
    end

    ---Save a QAngle.
    ---@param handle CBaseEntity # Entity to save on.
    ---@param name string # Name to save as.
    ---@param qangle QAngle # QAngle to save.
    function Storage.SaveQAngle(handle, name, qangle)
        handle = resolveHandle(handle)
        handle:SetContext(name..separator.."type", "qangle", 0)
        Storage.SaveNumber(handle, name .. ".x", qangle.x)
        Storage.SaveNumber(handle, name .. ".y", qangle.y)
        Storage.SaveNumber(handle, name .. ".z", qangle.z)
    end

    ---Save a table.
    ---
    ---May be ordered, unordered or mixed.
    ---
    ---May have nested tables.
    ---@param handle EntityHandle
    ---@param name string
    ---@param tbl table<any,any>
    function Storage.SaveTable(handle, name, tbl)
        handle = resolveHandle(handle)
        local indexCount = 0
        local keyCount = 0
        for key, value in pairs(tbl) do
            if type(key)=="number" then
                indexCount = indexCount + 1
                handle:SetContextNum(name.."index"..indexCount, key, 0)
            else
                keyCount = keyCount + 1
                handle:SetContext(name.."key"..keyCount, key, 0)
            end
            Storage.Save(handle, name..separator..key, value)
        end
        handle:SetContextNum(name..separator.."keyCount", keyCount, 0)
        handle:SetContextNum(name..separator.."indexCount", indexCount, 0)
        handle:SetContext(name..separator.."type", "table", 0)
    end

    ---Save an entity reference.
    ---
    ---Entity handles change between game sessions so this function
    ---modifies the passed entity to make sure it can keep track of it.
    ---@param handle CBaseEntity # Entity to save on.
    ---@param name string # Name to save as.
    ---@param entity EntityHandle # Entity to save.
    function Storage.SaveEntity(handle, name, entity)
        local ent_name = entity:GetName()
        local uniqueKey = DoUniqueString("saved_entity")
        if ent_name == "" then
            ent_name = uniqueKey
            entity:SetEntityName(ent_name)
        end
        -- setting attribute on saved entity
        entity:Attribute_SetIntValue(uniqueKey, 1)
        -- setting contexts for saving handle
        handle:SetContext(name, ent_name, 0)
        handle:SetContext(name..separator.."unique", uniqueKey, 0)
        handle:SetContext(name..separator.."type", "entity", 0)
    end

    ---Save a value.
    ---
    ---Uses type inference to save the value.
    ---If you are experiencing errors consider saving with one of the explicit type saves.
    ---@param handle CBaseEntity # Entity to save on.
    ---@param name string # Name to save as.
    ---@param value any # Value to save.
    function Storage.Save(handle, name, value)
        local t = type(value)
        if t=="string" then Storage.SaveString(handle, name, value)
        elseif t=="number" then Storage.SaveNumber(handle, name, value)
        elseif t=="boolean" then Storage.SaveBoolean(handle, name, value)
        elseif IsValidEntity(value) then Storage.SaveEntity(handle, name, value)
            -- Better way to determining base class?
            ---@diagnostic disable-next-line: undefined-field
        elseif value.__index==Vector().__index then Storage.SaveVector(handle, name, value)
            ---@diagnostic disable-next-line: undefined-field
        elseif value.__index==QAngle().__index then Storage.SaveQAngle(handle, name, value)
        elseif t=="table" then Storage.SaveTable(handle, name, value)
        else
            Warn("Value ["..tostring(value)..","..type(value).."] is not supported. Please open at issue on the github.")
        end
    end

    -------------
    -- LOADING --
    -------------

    ---Load a string.
    ---@param handle CBaseEntity # Entity to save on.
    ---@param name string # Name the string was saved as.
    ---@param default? string # Optional default value.
    ---@return string
    function Storage.LoadString(handle, name, default)
        handle = resolveHandle(handle)
        local t = handle:GetContext(name..separator.."type")
        local value = handle:GetContext(name)
        if not value or t ~= "string" then
            Warn("String " .. name .. " could not be loaded! ("..type(value)..", "..tostring(value)..")\n")
            return default
        end
        return value
    end

    ---Load a number.
    ---@param handle CBaseEntity # Entity to load from.
    ---@param name string # Name the number was saved as.
    ---@param default? number # Optional default value.
    ---@return number
    function Storage.LoadNumber(handle, name, default)
        handle = resolveHandle(handle)
        local t = handle:GetContext(name..separator.."type")
        local value = handle:GetContext(name)
        if not value or t ~= "number" then
            Warn("Number " .. name .. " could not be loaded! ("..type(value)..", "..tostring(value)..")\n")
            return default
        end
        return value
    end

    ---Load a boolean value.
    ---@param handle CBaseEntity # Entity to save on.
    ---@param name string # Name the boolean was saved as.
    ---@param default? boolean # Optional default value.
    ---@return boolean
    function Storage.LoadBoolean(handle, name, default)
        handle = resolveHandle(handle)
        local t = handle:GetContext(name..separator.."type")
        local value = handle:GetContext(name)
        if not value or t ~= "boolean" then
            Warn("Boolean " .. name .. " could not be loaded! ("..type(value)..", "..tostring(value)..")\n")
            return default
        end
        return value == 1
    end

    ---Load a Vector.
    ---@param handle CBaseEntity # Entity to save on.
    ---@param name string # Name the Vector was saved as.
    ---@param default? Vector # Optional default value.
    ---@return Vector
    function Storage.LoadVector(handle, name, default)
        handle = resolveHandle(handle)
        local t = handle:GetContext(name..separator.."type")
        if t ~= "vector" then
            Warn("Vector " .. name .. " could not be loaded!\n")
            return default
        end
        local x = handle:GetContext(name .. ".x") or 0
        local y = handle:GetContext(name .. ".y") or 0
        local z = handle:GetContext(name .. ".z") or 0
        return Vector(x, y, z)
    end

    ---Load a QAngle.
    ---@param handle CBaseEntity # Entity to save on.
    ---@param name string # Name the QAngle was saved as.
    ---@param default? QAngle # Optional default value.
    ---@return QAngle
    function Storage.LoadQAngle(handle, name, default)
        handle = resolveHandle(handle)
        local t = handle:GetContext(name..separator.."type")
        if t ~= "qangle" then
            Warn("QAngle " .. name .. " could not be loaded!\n")
            return default
        end
        local x = handle:GetContext(name .. ".x") or 0
        local y = handle:GetContext(name .. ".y") or 0
        local z = handle:GetContext(name .. ".z") or 0
        return QAngle(x, y, z)
    end

    ---Load a table.
    ---@param handle EntityHandle
    ---@param name string
    ---@param default table<any,any>
    function Storage.LoadTable(handle, name, default)
        handle = resolveHandle(handle)
        local keyCount = handle:GetContext(name..separator.."keyCount")
        local indexCount = handle:GetContext(name..separator.."indexCount")
        if not keyCount and not indexCount then
            Warn("Table " .. name .. " could not be loaded!\n")
            return default
        end

        local tbl, s_key = {}, name..separator
        for i = 1, indexCount do
            local key = handle:GetContext(name.."index"..i)
            tbl[tonumber(key)] = Storage.Load(handle, s_key..key)
        end
        for i = 1, keyCount do
            local key = handle:GetContext(name.."key"..i)
            tbl[key] = Storage.Load(handle, s_key..key)
        end
        return tbl
    end

    ---Load an entity.
    ---@param handle CBaseEntity # Entity to save on.
    ---@param name string # Name to save as.
    ---@param default EntityHandle # Optional default value.
    ---@return EntityHandle
    function Storage.LoadEntity(handle, name, default)
        handle = resolveHandle(handle)
        local t = handle:GetContext(name..separator.."type")
        local uniqueKey = handle:GetContext(name..separator.."unique")
        local ent_name = handle:GetContext(name)
        if not ent_name or t ~= "entity" then
            Warn("Entity '" .. name .. "' could not be loaded! ("..type(ent_name)..", "..tostring(ent_name)..")\n")
            return default
        end
        local ents = Entities:FindAllByName(ent_name)
        if not ents then
            Warn("No entities of '" .. name .. "' found with saved name '" .. ent_name .. "', returning default.\n")
            return default
        end
        for _, ent in ipairs(ents) do
            if ent:Attribute_GetIntValue(uniqueKey, 0) == 1 then
                return ent
            end
        end
        -- Return default if no entities with saved value.
        Warn("No entities of '" .. name .. "' have saved attribute! Returning default.\n")
        return default
    end

    ---Load a value.
    ---@param handle CBaseEntity # Entity to load from.
    ---@param name string # Name the value was saved as.
    ---@param default? any # Optional default value.
    ---@return any
    function Storage.Load(handle, name, default)
        handle = resolveHandle(handle)
        local t = handle:GetContext(name..separator.."type")
        if not t then
            Warn("Value " .. name .. " could not be loaded!\n")
            return default
        end
        if t=="string" then return Storage.LoadString(handle, name, default)
        elseif t=="number" then return Storage.LoadNumber(handle, name, default)
        elseif t=="boolean" then return Storage.LoadBoolean(handle, name, default)
        elseif t=="vector" then return Storage.LoadVector(handle, name, default)
        elseif t=="qangle" then return Storage.LoadQAngle(handle, name, default)
        elseif t=="table" then return Storage.LoadTable(handle, name, default)
        elseif t=="entity" then return Storage.LoadEntity(handle, name, default)
        else
            Warn("Unknown type '"..t.."' for name '"..name.."'\n")
            return default
        end
    end

    -- Done one by one for code hint purposes
    CBaseEntity.SaveString  = Storage.SaveString
    CBaseEntity.SaveNumber  = Storage.SaveNumber
    CBaseEntity.SaveBoolean = Storage.SaveBoolean
    CBaseEntity.SaveVector  = Storage.SaveVector
    CBaseEntity.SaveQAngle  = Storage.SaveQAngle
    CBaseEntity.SaveTable   = Storage.SaveTable
    CBaseEntity.SaveEntity  = Storage.SaveEntity
    CBaseEntity.Save        = Storage.Save

    CBaseEntity.LoadString  = Storage.LoadString
    CBaseEntity.LoadNumber  = Storage.LoadNumber
    CBaseEntity.LoadBoolean = Storage.LoadBoolean
    CBaseEntity.LoadVector  = Storage.LoadVector
    CBaseEntity.LoadQAngle  = Storage.LoadQAngle
    CBaseEntity.LoadTable   = Storage.LoadTable
    CBaseEntity.LoadEntity  = Storage.LoadEntity
    CBaseEntity.Load        = Storage.Load
end
