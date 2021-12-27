--[[
    v2.0.0

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

    This script can also be loaded on a per entity basis into the script's scope
    using the following line:

    DoIncludeScript("util/storage", thisEntity:GetPrivateScriptScope())

    If you have extravaganza.code-snippets then you can add this quickly by
    starting to type "storage".

    This allows you to save values to the entity running the script easily:

    thisEntity:SaveNumber("hp", thisEntity:GetHealth())
    thisEntity:SetHealth(thisEntity:LoadNumber("hp"))
]]


---Resolves the given handle
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
        Warning("Trying to save a global value before player has spawned!\n")
        return nil
    end
    return player

    -- if handle == Storage then
    --     return thisEntity or GetListenServerHost()
    -- end
    -- return handle or thisEntity or GetListenServerHost()
end

local separator = ".:|:."

if thisEntity then
    print("Storage is being included in an entity context...")

    require "util.storage"

    -- Done one by one for code hint purposes
    thisEntity.SaveString  = _G.Storage.SaveString
    thisEntity.SaveNumber  = _G.Storage.SaveNumber
    thisEntity.SaveBoolean = _G.Storage.SaveBoolean
    thisEntity.SaveVector  = _G.Storage.SaveVector
    thisEntity.SaveQAngle  = _G.Storage.SaveQAngle
    -- thisEntity.SaveArray   = _G.Storage.SaveArray
    thisEntity.SaveTable   = _G.Storage.SaveTable
    thisEntity.SaveEntity  = _G.Storage.SaveEntity
    thisEntity.Save        = _G.Storage.Save

    thisEntity.LoadString  = _G.Storage.LoadString
    thisEntity.LoadNumber  = _G.Storage.LoadNumber
    thisEntity.LoadBoolean = _G.Storage.LoadBoolean
    thisEntity.LoadVector  = _G.Storage.LoadVector
    thisEntity.LoadQAngle  = _G.Storage.LoadQAngle
    -- thisEntity.LoadArray   = _G.Storage.LoadArray
    thisEntity.LoadTable   = _G.Storage.LoadTable
    thisEntity.LoadEntity  = _G.Storage.LoadEntity
    thisEntity.Load        = _G.Storage.Load

    -- Can be done with a loop:
    -- for funcName, func in pairs(_G.Storage) do
    --     thisEntity[funcName] = func
    -- end
else
    print("Storage is being required in a global context...")
    Storage = {}

    ------------
    -- SAVING --
    ------------

    ---Save a string.
    ---@param handle CBaseEntity # Entity to save on.
    ---@param name string # Name to save as.
    ---@param value string # String to save.
    function Storage.SaveString(handle, name, value)
        handle = resolveHandle(handle)
        if not handle then
            Warning("Invalid save handle ("..tostring(handle)..")!\n")
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
            Warning("Invalid save handle ("..tostring(handle)..")!\n")
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

    --[[
    ---Save an ordered array of numbers or strings.
    ---@param handle CBaseEntity # Entity to save on.
    ---@param name string # Name to save as.
    ---@param array any[] # Array to save.
    function Storage.SaveArray(handle, name, array)
        -- Save number of items first
        Storage.SaveNumber(handle, name, #array)
        -- Then save values
        for index, value in ipairs(array) do
            local t = type(value)
            if t == "number" then
                Storage.SaveNumber(handle, name..index, value)
            elseif t == "string" then
                Storage.SaveString(handle, name..index, value)
            end
        end
    end
    ]]

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
        local indices = ""
        local keys = ""
        for key, value in pairs(tbl) do
            if type(key)=="number" then
                indices = indices .. key .. separator
            else
                keys = keys .. key .. separator
            end
            Storage.Save(handle, name..separator.."keys"..separator..key, value)
        end
        keys = keys:sub(1, #keys-1)
        -- If context value starts with number it will ignore other characters so prefix a char.
        indices = "|"..indices:sub(1, #indices-1)
        handle:SetContext(name..separator.."keys", keys, 0)
        handle:SetContext(name..separator.."indices", indices, 0)
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
        if ent_name == "" then
            ent_name = DoUniqueString("saved_entity")
            entity:SetEntityName(ent_name)
        end
        entity:Attribute_SetIntValue("saved_entity"..name, 1)
        handle:SetContext(name, ent_name, 0)
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
            -- Better way to determining base class?
        elseif IsValidEntity(value) then Storage.SaveString(handle, name..".type", "entity") Storage.SaveEntity(handle, name, value)
        elseif value.__index==Vector().__index then Storage.SaveVector(handle, name, value)
        ---@diagnostic disable-next-line: undefined-field
        elseif value.__index==QAngle().__index then Storage.SaveQAngle(handle, name, value)
        elseif t=="table" then Storage.SaveTable(handle, name, value)
            -- if #value > 0 then Storage.SaveString(handle, name..".type", "array") Storage.SaveArray(handle, name, value)
            --     -- else Storage.SaveTable(handle, name, value)
            -- end
        else
            Warning("Value ["..tostring(value)..","..type(value).."] is not supported. Please open at issue on the github.")
        end
    end

    -------------
    -- LOADING --
    -------------

    --[[
    ---Load a number or string by name, whichever was stored.
    ---@param handle CBaseEntity # Entity to load from.
    ---@param name string # Name the number or string was saved as.
    ---@param default? string # Optional default value.
    ---@return number|string
    function Storage.LoadNumberOrString(handle, name, default)
        local value = resolveHandle(handle):GetContext(name)
        if not value then
            Warning("Number or string " .. name .. " could not be loaded! ("..type(value)..", "..tostring(value)..")\n")
            return default
        end
        return value
    end
    ]]

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
            Warning("String " .. name .. " could not be loaded! ("..type(value)..", "..tostring(value)..")\n")
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
            Warning("Number " .. name .. " could not be loaded! ("..type(value)..", "..tostring(value)..")\n")
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
            Warning("Boolean " .. name .. " could not be loaded! ("..type(value)..", "..tostring(value)..")\n")
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
            Warning("Vector " .. name .. " could not be loaded!\n")
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
            Warning("QAngle " .. name .. " could not be loaded!\n")
            return default
        end
        local x = handle:GetContext(name .. ".x") or 0
        local y = handle:GetContext(name .. ".y") or 0
        local z = handle:GetContext(name .. ".z") or 0
        return QAngle(x, y, z)
    end

    --[[
    ---Load an array.
    ---@param handle CBaseEntity # Entity to save on.
    ---@param name string # Name the array was saved as.
    ---@param default? any[] # Optional default value.
    ---@return any[]
    function Storage.LoadArray(handle, name, default)
        handle = resolveHandle(handle)
        local arr = {}
        local len = handle:GetContext(name)
        if not len then
            Warning("Array " .. name .. " could not be loaded!\n")
            return default
        end
        for i = 1, len do
            arr[#arr+1] = handle:GetContext(name..i)
        end
        return arr
    end
    ]]

    ---Load a table.
    ---@param handle EntityHandle
    ---@param name string
    ---@param default table<any,any>
    function Storage.LoadTable(handle, name, default)
        handle = resolveHandle(handle)
        local keysPacked = handle:GetContext(name..separator.."keys")
        local indicesPacked = handle:GetContext(name..separator.."indices")
        if not keysPacked and not indicesPacked then
            Warning("Table " .. name .. " could not be loaded!\n")
            return default
        end
        keysPacked = keysPacked or ""
        indicesPacked = indicesPacked or ""
        --                         Remove the prefixed char
        local indices = vlua.split(indicesPacked:sub(2, #indicesPacked), separator)
        local keys = vlua.split(keysPacked, separator)
        local tbl, s_keys = {}, name..separator.."keys"..separator
        for _, index in pairs(indices) do
            tbl[tonumber(index)] = Storage.Load(handle, s_keys..index)
        end
        for _, key in pairs(keys) do
            tbl[key] = Storage.Load(handle, s_keys..key)
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
        local ent_name = handle:GetContext(name)
        if not ent_name or t ~= "entity" then
            Warning("Entity '" .. name .. "' could not be loaded! ("..type(ent_name)..", "..tostring(ent_name)..")\n")
            return default
        end
        local ents = Entities:FindAllByName(ent_name)
        if not ents then
            Warning("No entities of '" .. name .. "' found with saved name '" .. ent_name .. "', returning default.\n")
            return default
        end
        for _, ent in ipairs(ents) do
            if ent:Attribute_GetIntValue("saved_entity"..name, 0) == 1 then
                return ent
            end
        end
        -- Return default if no entities with saved value.
        Warning("No entities of '" .. name .. "' have saved attribute! Returning default.\n")
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
            Warning("Value " .. name .. " could not be loaded!\n")
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
            Warning("Unknown type '"..t.."' for name '"..name.."'\n")
            return default
        end
    end
end
