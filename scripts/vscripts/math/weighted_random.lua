--[[
    v1.2.1
    Weighted random allows you to assign chances to tables.

    If not using `vscripts/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "math.weighted_random"
    ```

    ======================================== Usage ========================================

    The WeightedRandom() function takes a list of tables where each one must at least
    contain a key with the name "weight" pointing to a number value.
    The table may contain any other keys/values you wish and will be returned if this weight is chosen.

    Weights do not need to be [0-1] range.

    ```lua
    local wr = WeightedRandom({
        { weight = 1, name = "Common" },
        { weight = 0.75, name = "Semi-common" },
        { weight = 0.5, name = "Uncommon" },
        { weight = 0.25, name = "Rare" },
        { weight = 0.1, name = "Extremely rare" },
    })

    for i = 1, 20 do
        print(wr:Random().name)
    end
    ```
]]

---
---Weighted random allows you to assign chances to tables.
---
---Should be loaded into global scope by using the following line:
---
---      require "math.weighted_random"
---
---@class WeightedRandom
local WeightedRandomBaseClass = {
    ---Root list containing all weighted tables.
    ---@type table[]
    ItemPool = {},
    ---If true this weighted random will use math.random().
    ---Otherwise it uses Valve's RandomFloat().
    UseRandomSeed = false,
}
WeightedRandomBaseClass.__index = WeightedRandomBaseClass

if pcall(require, "storage") then
    Storage.RegisterType("WeightedRandom", WeightedRandomBaseClass)

    ---
    ---**Static Function**
    ---
    ---Helper function for saving the `WeightedRandom`.
    ---
    ---@param handle EntityHandle # The entity to save on.
    ---@param name string # The name to save as.
    ---@param wr WeightedRandom # The stack to save.
    ---@return boolean # If the save was successful.
    function WeightedRandomBaseClass.__save(handle, name, wr)
        return Storage.SaveTableCustom(handle, name, wr, "WeightedRandom")
    end

    ---
    ---**Static Function**
    ---
    ---Helper function for loading the `WeightedRandom`.
    ---
    ---@param handle EntityHandle # Entity to load from.
    ---@param name string # Name to load.
    ---@return WeightedRandom|nil
    function WeightedRandomBaseClass.__load(handle, name)
        local wr = Storage.LoadTableCustom(handle, name, "WeightedRandom")
        if wr == nil then return nil end
        return setmetatable(wr, WeightedRandomBaseClass)
    end

    Storage.SaveWeightedRandom = WeightedRandomBaseClass.__save
    CBaseEntity.SaveWeightedRandom = Storage.SaveWeightedRandom

    ---
    ---Load a WeightedRandom.
    ---
    ---@generic T
    ---@param handle EntityHandle # Entity to load from.
    ---@param name string # Name the WeightedRandom was saved as.
    ---@param default? T # Optional default value.
    ---@return WeightedRandom|T
    Storage.LoadWeightedRandom = function(handle, name, default)
        local wr = WeightedRandomBaseClass.__load(handle, name)
        if wr == nil then
            return default
        end
        return wr
    end
    CBaseEntity.LoadWeightedRandom = Storage.LoadWeightedRandom
end

---
---Add a table value with an associated weight.
---If `tbl` already has a weight key then `weight` parameter can be omitted.
---
---Note: The table `tbl` is not cloned, the given reference is used.
---
---@param tbl table # Table of values that will be returned.
---@param weight? number # Weight for this table.
function WeightedRandomBaseClass:Add(tbl, weight)
    if weight ~= nil then tbl.weight = weight end
    self.ItemPool[#self.ItemPool+1] = tbl
end
---
---Get the total weight of this weighted random object.
---
---@return number # The sum of all weights.
function WeightedRandomBaseClass:TotalWeight()
    local weight_sum = 0
    for _,item in ipairs(self.ItemPool) do
        weight_sum = weight_sum + item.weight
    end
    return weight_sum
end

---
---Pick a random table from the list of weighted tables.
---
---@return table
function WeightedRandomBaseClass:Random()
    local weight_sum = self:TotalWeight()
    local weight_remaining
    if self.UseRandomSeed then
        weight_remaining = math.random(0, weight_sum)
    else
        weight_remaining = RandomFloat(0, weight_sum)
    end
    for _,item in ipairs(self.ItemPool) do
        weight_remaining = weight_remaining - item.weight
        if weight_remaining < 0 then
            return item
        end
    end
    -- Return to last item just in case (should never reach here.)
    return self.ItemPool[#self.ItemPool]
end

---
---Create a new WeightedRandom object with given weights.
---
---E.g.
---
---    local wr = WeightedRandom({
---        { weight = 1, name = "Common" },
---        { weight = 0.75, name = "Semi-common" },
---        { weight = 0.5, name = "Uncommon" },
---        { weight = 0.25, name = "Rare" },
---        { weight = 0.1, name = "Extremely rare" },
---    })
---
---Params:
---
---@param weights table[]|"{\n\t{ weight = 1 },\n}"
---@return WeightedRandom
function WeightedRandom(weights)
    return setmetatable({ItemPool = weights or {}}, WeightedRandomBaseClass)
end

