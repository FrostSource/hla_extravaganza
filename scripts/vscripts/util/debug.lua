--[[
    Debug utility functions.

    Load this file at game start using the following line:

        require "util.debug"

]]
Debug = Debug or {}

---Prints the given table contents to the console.
---@param t table
Debug.PrintTable = function(t)
    local pair
    if #t > 0 then
        pair = ipairs(t)
    else
        pair = pairs(t)
    end
    for k,v in pair do
        print(k, v)
    end
end
