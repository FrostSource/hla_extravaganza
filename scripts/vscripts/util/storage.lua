
--[[
    Helps with saving/loading values for persistency between game sessions.
    Values are saved into the entity running this script. If the entity
    is killed the values cannot be retrieved during that game session.

    This script is loaded on a per script basis into the script's scope.
    Using the following line:

    DoIncludeScript("util/storage", thisEntity:GetPrivateScriptScope())

    -

    Functions are accessed through the Storage table.

    Examples of saving/loading the following local values that might be defined
    at the top of the file:

    local origin = origin or thisEntity:GetOrigin()
    local hp     = hp     or thisEntity:GetHealth()
    local name   = name   or thisEntity:GetName()

    Saving:

    Storage.SaveVector("origin", origin)
    Storage.SaveNumber("hp", hp)
    Storage.SaveString("name", name)

    Loading:

    function Activate(activateType)
        -- 2 indicates a loaded game, this is typically where you load values
        -- but loading can be done at any point during the game
        if activateType == 2 then
            origin = Storage.LoadVector("origin")
            hp     = Storage.LoadNumber("hp")
            name   = Storage.LoadString("name")
        end
    end
]]

Storage = Storage or {}

---Save a single number to this entity.
---@param name string Name to save as
---@param value number Variable name
Storage.SaveNumber = function(name, value)
    thisEntity:SetContextNum(name, value, 0)
end

---Save a single string to this entity.
---@param name string Name to save as
---@param value string Variable name
Storage.SaveString = function(name, value)
    thisEntity:SetContext(name, value, 0)
end

---Save a Vector to this entity.
---@param name string Name to save as
---@param vector Vector Variable name
Storage.SaveVector = function(name, vector)
    Storage.SaveNumber(name .. ".x", vector.x)
    Storage.SaveNumber(name .. ".y", vector.y)
    Storage.SaveNumber(name .. ".z", vector.z)
end

---Save a QAngle to this entity.
---@param name string Name to save as
---@param qangle QAngle Variable name
Storage.SaveQAngle = function(name, qangle)
    Storage.SaveNumber(name .. ".x", qangle.x)
    Storage.SaveNumber(name .. ".y", qangle.y)
    Storage.SaveNumber(name .. ".z", qangle.z)
end

---Load a number from this entity.
---@param name string Name the variable was saved as.
---@return number
Storage.LoadNumber = function(name)
    local value = thisEntity:GetContext(name)
    if not value or type(value) ~= "number" then
        return Warning("Number " .. name .. " could not be loaded!")
    end
    return value
end

---Load a string from this entity.
---@param name string Name the variable was saved as.
---@return string
Storage.LoadString = function(name)
    local value = thisEntity:GetContext(name)
    if not value or type(value) ~= "string" then
        return Warning("String " .. name .. " could not be loaded!")
    end
    return value
end

---Load a Vector from this entity.
---@param name string Name the Vector was saved as.
---@return Vector
Storage.LoadVector = function(name)
    local x = Storage.LoadNumber(name .. ".x")
    if not x then
        return Warning("Vector " .. name .. " could not be loaded!")
    end
    local y = Storage.LoadNumber(name .. ".y")
    local z = Storage.LoadNumber(name .. ".z")
    return Vector(x, y, z)
end

---Load a QAngle from this entity.
---@param name string Name the QAngle was saved as.
---@return QAngle
Storage.LoadQAngle = function(name)
    local x = Storage.LoadNumber(name .. ".x")
    if not x then
        return Warning("QAngle " .. name .. " could not be loaded!")
    end
    local y = Storage.LoadNumber(name .. ".y")
    local z = Storage.LoadNumber(name .. ".z")
    return QAngle(x, y, z)
end

