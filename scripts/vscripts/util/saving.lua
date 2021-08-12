
--[[
    Helps with saving/loading values for persistency between game sessions.
    Values are saved into the entity running this script. If the entity
    is killed the values cannot be retrieved during that game session.

    This script is loaded on a per script basis into the script's scope.
    Using the following line:

    DoIncludeScript("util/saving", thisEntity:GetPrivateScriptScope())

    -

    Examples of saving/loading the following local values that might be defined
    at the top of the file:

    local origin = origin or thisEntity:GetOrigin()
    local hp = hp or thisEntity:GetHealth()
    local name = name or thisEntity:GetName()

    Saving:

    SaveVector("origin", origin)
    SaveNumber("hp", hp)
    SaveString("name", name)

    Loading:

    function Activate(activateType)
        -- 2 indicates a loaded game, this is typically where you load values
        -- but loading can be done at any point during the game
        if activateType == 2 then
            origin = LoadVector("origin")
            hp = LoadNumber("hp")
            name = LoadString("name")
        end
    end
]]

---Save a single number to this entity.
---@param name string Name to save as
---@param value number Variable name
function SaveNumber(name, value)
    thisEntity:SetContextNum(name, value, 0)
end

---Save a single string to this entity.
---@param name string Name to save as
---@param value string Variable name
function SaveString(name, value)
    thisEntity:SetContext(name, value, 0)
end

---Save a Vector to this entity.
---@param name string Name to save as
---@param vector Vector Variable name
function SaveVector(name, vector)
    SaveNumber(name .. ".x", vector.x)
    SaveNumber(name .. ".y", vector.y)
    SaveNumber(name .. ".z", vector.z)
end

---Save a QAngle to this entity.
---@param name string Name to save as
---@param qangle QAngle Variable name
function SaveQAngle(name, qangle)
    SaveNumber(name .. ".x", qangle.x)
    SaveNumber(name .. ".y", qangle.y)
    SaveNumber(name .. ".z", qangle.z)
end

---Load a number from this entity.
---@param name string Name the variable was saved as.
---@return number
function LoadNumber(name)
    local value = thisEntity:GetContext(name)
    if not value or type(value) ~= "number" then
        return Warning("Number " .. name .. " could not be loaded!")
    end
    return value
end

---Load a string from this entity.
---@param name string Name the variable was saved as.
---@return string
function LoadString(name)
    local value = thisEntity:GetContext(name)
    if not value or type(value) ~= "string" then
        return Warning("String " .. name .. " could not be loaded!")
    end
    return value
end

---Load a Vector from this entity.
---@param name string Name the Vector was saved as.
---@return Vector
function LoadVector(name)
    local x = LoadNumber(name .. ".x")
    if not x then
        return Warning("Vector " .. name .. " could not be loaded!")
    end
    local y = LoadNumber(name .. ".y")
    local z = LoadNumber(name .. ".z")
    return Vector(x, y, z)
end

---Load a QAngle from this entity.
---@param name string Name the QAngle was saved as.
---@return QAngle
function LoadQAngle(name)
    local x = LoadNumber(name .. ".x")
    if not x then
        return Warning("QAngle " .. name .. " could not be loaded!")
    end
    local y = LoadNumber(name .. ".y")
    local z = LoadNumber(name .. ".z")
    return QAngle(x, y, z)
end

