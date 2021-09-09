
--[[
    Weighted random allows you to assign chances to values.

    Can be included on a per script basis with the following line:

        DoIncludeScript("util/weighted_random", thisEntity:GetPrivateScriptScope())

    Or loaded into global scope for all scripts using the following line:

        require "util.weighted_random"

    -

    The WeightedRandom() function takes a list of tables where each one must at least
    contain a key with the name "weight" as a number value. The table may contain any
    other keys/values you wish and will be returned if this weight is chosen.

    Weights do not need to be [0-1] range.

    Usage example:

    local wr = WeightedRandom({
        { weight = 1, name = "one" },
        { weight = 0.7, name = "two" },
        { weight = 0.5, name = "three" },
        { weight = 0.1, name = "four" },
    })

    for i = 1, 20 do
        print(wr:Random().name)
    end
]]

---@class WeightedRandomObject
---@field item_pool table[]
---@field TotalWeight fun(self: WeightedRandomObject): number
---@field Random fun(self: WeightedRandomObject): table

---Returns a WeightedRandom object with given weights.
---@param weights table[]|"{\n\t{ weight = 1 },\n}"
---@return WeightedRandomObject
WeightedRandom = function(weights)
    ---@type WeightedRandomObject
    local instance = {
        ---@type table[]
        item_pool = weights or {},

        ---Returns the total weight of this weighted random object.
        ---@param self WeightedRandomObject
        ---@return number
        TotalWeight = function(self)
            local weight_sum = 0
            for _,item in ipairs(self.item_pool) do
                weight_sum = weight_sum + item.weight
            end
            return weight_sum
        end,

        ---Returns a random table from the list of weighted tables.
        ---@param self WeightedRandomObject
        ---@return table
        Random = function(self)
            local weight_sum = self:TotalWeight()
            local weight_remaining = RandomFloat(0, weight_sum)
            for _,item in ipairs(self.item_pool) do
                weight_remaining = weight_remaining - item.weight
                if weight_remaining < 0 then
                    return item
                end
            end
        end
    }

    return instance
end
