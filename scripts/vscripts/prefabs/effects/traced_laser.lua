--[[
    v2.0.0
    https://github.com/FrostSource/hla_extravaganza

    Script for prefab `maps\prefabs\effects\traced_laser\traced_laser.vmap`
]]
if thisEntity then if thisEntity:GetPrivateScriptScope().__load then return else thisEntity:GetPrivateScriptScope().__load = true end else return end
local max_trace_distance = 1024
local ignored_entity = nil
local target_handle = nil

local function UpdateLaser()
    local traceTable = {
        startpos = thisEntity:GetOrigin(),
        endpos = thisEntity:GetOrigin() + thisEntity:GetForwardVector() * max_trace_distance,
        ignore = ignored_entity
    }
    TraceLine(traceTable)
    target_handle:SetOrigin(traceTable.pos)
    if traceTable.hit then
        target_handle:SetForwardVector(traceTable.normal)
    else
        target_handle:SetForwardVector(thisEntity:GetForwardVector())
    end
    return 0
end

---
---Enables the laser to think and starts the particle.
---
local function Enable()
    thisEntity:SetContextNum("IsEnabled", 1, 0)
    thisEntity:SetContextThink("UpdateLaser", UpdateLaser, 0)
    DoEntFireByInstanceHandle(thisEntity, "Start", "", 0, nil, nil)
end
thisEntity:GetPrivateScriptScope().Enable = Enable

---
---Disables the laser from thinking and stops the particle.
---
local function Disable()
    thisEntity:SetContextNum("IsEnabled", 0, 0)
    thisEntity:SetContextThink("UpdateLaser", nil, 0)
    DoEntFireByInstanceHandle(thisEntity, "StopPlayEndCap", "", 0, nil, nil)
end
thisEntity:GetPrivateScriptScope().Disable = Disable

---
---Sets the color by moving the color entity.
---
---@param red integer
---@param green integer
---@param blue integer
local function SetColor(red, green, blue)
    local c = Entities:FindByName(nil, thisEntity:GetName().."_color")
    if c then
        c:SetOrigin(Vector(red, green, blue))
    end
end
thisEntity:GetPrivateScriptScope().SetColor = SetColor

---@param spawnkeys CScriptKeyValues
function Spawn(spawnkeys)
    local traceDist = tonumber(spawnkeys:GetValue("cpoint7_parent")) or 1024
    thisEntity:SetContextNum("MaxTraceDistance", traceDist, 0)

    local ignoredName = spawnkeys:GetValue("cpoint62") or ""
    thisEntity:SetContext("IgnoredEntityName", ignoredName, 0)

    local startActive = spawnkeys:GetValue("start_active") or 0
    thisEntity:SetContextNum("IsEnabled", startActive and 1 or 0, 0)

    -- Set color entity position
    local colorFromScales = spawnkeys:GetValue("local.scales")
    thisEntity:SetContextThink("color", function()
        SetColor(colorFromScales.x,colorFromScales.y,colorFromScales.z)
    end, 0)
end

---@param activateType "0"|"1"|"2"
function Activate(activateType)

    -- Load values

    ignored_entity = thisEntity:GetContext("IgnoredEntityName")--[[@as string]]
    if ignored_entity then
        ignored_entity = Entities:FindByName(nil, ignored_entity)
    end

    max_trace_distance = thisEntity:GetContext("MaxTraceDistance")--[[@as number]]

    target_handle = Entities:FindByName(nil, thisEntity:GetName().."_target")

    if thisEntity:GetContext("IsEnabled") == 1 then
        Enable()
    end

    print("traced_laser: ignored("..tostring(ignored_entity)..") distance("..tostring(max_trace_distance)..") target("..tostring(target_handle)..")")

end