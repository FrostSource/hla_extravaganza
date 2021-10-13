--[[
    Debug utility functions.

    Load this file at game start using the following line:

        require "util.debug"

]]
Debug = Debug or {}

---Prints the given table contents to the console.
---@param t table
function Debug:PrintTable(t)
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

function Debug:PrintAllEntities()
    local e = Entities:First()
    while e ~= nil do
        print(e:GetClassname(), e:GetName(), e:GetModelName())
        e = Entities:Next(e)
    end
end
