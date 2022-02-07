--[[
    v2.0.0
    Prefab specific functions for maps/prefabs/logic/logic_weighted_random/logic_weighted_random.vmap
]]
require "util.storage"
require "util.weighted_random"

---@type WeightedRandom
local wr

local function PickRandomWeight(data)
    thisEntity:FireOutput("On"..wr:Random().case, data.activator, thisEntity, nil, 0)
end

function Spawn(spawnkeys)
    local weights = {}
    for i = 1, 16 do
        local case = "Case" .. (i < 10 and "0" or "") .. i
        local weight = spawnkeys:GetValue(case)
        weight = tonumber(weight)
        if weight ~= nil and weight ~= 0 then
            weights[#weights+1] = { weight = weight, case = case}
        end
    end
    thisEntity:SaveTable("Weights", weights)
    wr = WeightedRandom(weights)
end

local function ready(saveLoaded)
    if saveLoaded then
        local weights = thisEntity:LoadTable("Weights", {})
        wr = WeightedRandom(weights)
    end
end

-- Fix for script executing twice on restore.
-- This binds to the new local ready function on second execution.
if thisEntity:GetPrivateScriptScope().savewasloaded then
    thisEntity:SetContextThink("init", function() ready(true) end, 0)
end

---@param activateType "0"|"1"|"2"
function Activate(activateType)
    -- If game is being restored then set the script scope ready for next execution.
    if activateType == 2 then
        thisEntity:GetPrivateScriptScope().savewasloaded = true
        return
    end
    -- Otherwise just run the ready function after "instant" delay (player will be ready).
    thisEntity:SetContextThink("init", function() ready(false) end, 0)
end

-- Add local functions to private script scope to avoid environment pollution.
local _a,_b=1,thisEntity:GetPrivateScriptScope()while true do local _c,_d=debug.getlocal(1,_a)if _c==nil then break end;if type(_d)=='function'then _b[_c]=_d end;_a=1+_a end















--[[
---@param spawnkeys CScriptKeyValues
function Spawn(spawnkeys)
    local weights = {}
    for i = 1, 16 do
        local case = "Case" .. (i < 10 and "0" or "") .. i
        local weight = spawnkeys:GetValue(case)
        weight = tonumber(weight)
        if weight ~= nil and weight ~= 0 then
            weights[#weights+1] = { weight = weight, case = case}
            -- thisEntity:Attribute_SetFloatValue(case, weight)
            thisEntity:SaveNumber(case, weight)
            print(case, weight)
        end
    end
    wr = WeightedRandom(weights)
end

---@param activateType "0"|"1"|"2"
function Activate(activateType)
    if activateType == 2 then
        local weights = {}
        for i = 1, 16 do
            local case = "Case" .. (i < 10 and "0" or "") .. i
            local weight = thisEntity:Attribute_GetFloatValue(case, 0)
            if weight ~= 0 then
                weights[#weights+1] = { weight = weight, case = case}
            end
        end
        WR = WeightedRandom(weights)
    end
end

function PickRandomWeight(data)
    thisEntity:FireOutput("On"..WR:Random().case, data.activator, data.caller, {}, 0)
end
]]
