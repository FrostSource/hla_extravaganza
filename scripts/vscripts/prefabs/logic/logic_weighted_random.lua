--[[
    v2.1.0
    https://github.com/FrostSource/hla_extravaganza

    Prefab specific functions for maps/prefabs/logic/logic_weighted_random/logic_weighted_random.vmap
]]
if thisEntity then if thisEntity:GetPrivateScriptScope().__load then return else thisEntity:GetPrivateScriptScope().__load = true end else return end
require "storage"
require "math.weighted_random"

---@type WeightedRandom
local wr

---Pick and fire a random case output.
---@param data IOParams
local function PickRandomWeight(data)
    thisEntity:FireOutput("On"..wr:Random().case, data.activator, thisEntity, nil, 0)
end
thisEntity:GetPrivateScriptScope().PickRandomWeight = PickRandomWeight

---@param activateType 0|1|2
function Activate(activateType)
    if activateType == 2 then
        wr = thisEntity:LoadWeightedRandom("Weights")
        if wr == nil then
            Warning("logic_weighted_random.lua could not load weights!")
        end
    end
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
    wr = WeightedRandom(weights)
    thisEntity:SaveWeightedRandom("Weights", wr)
end
