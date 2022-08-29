--[[
    v1.0.0
    https://github.com/FrostSource/hla_extravaganza

    Debug utility functions.

    Load this file at game start using the following line:

        require "debug.core"

]]
Debug = {}

---Prints useful entity information about a list of entities, such as classname and model.
---@param list EntityHandle[]
function Debug.PrintEntityList(list)
    print(string.format("\n%-12s %-40s %-40s %-40s %-60s","Handle", "Classname:", "Name:", "Model Name:", "Parent Class"))
    print(string.format("%-12s %-40s %-40s %-40s %-60s",  "------", "----------", "-----", "-----------", "------------"))
    for _, ent in ipairs(list) do
        print(string.format("%-12s %-40s %-40s %-40s %-60s", ent, ent:GetClassname(), ent:GetName(), ent:GetModelName(), ent:GetMoveParent() and ent:GetMoveParent():GetClassname() or "" ))
    end
    print()
end

---Prints information about all existing entities.
function Debug.PrintAllEntities()
    local list = {}
    local e = Entities:First()
    while e ~= nil do
        list[#list+1] = e
        e = Entities:Next(e)
    end
    Debug.PrintEntityList(list)
end

---Prints information about all entities within a sphere.
function Debug.PrintAllEntitiesInSphere(origin, radius)
    Debug.PrintEntityList(Entities:FindAllInSphere(origin, radius))
end

---Prints the keys/values of a table and any tested tables.
---
---This is different from `DeepPrintTable` in that it will not print members of entity handles.
---@param tbl table
---@param prefix? string
function Debug.PrintTable(tbl, prefix)
    prefix = prefix or ""
    local visited = {tbl}
    print(prefix.."{")
    for key, value in pairs(tbl) do
        print( string.format( "\t%s%-32s %s", prefix, key, "= " .. (type(value) == "string" and ("\"" .. tostring(value) .. "\"") or tostring(value)) .. " ("..type(value)..")" ) )
        if type(value) == "table" and not vlua.find(visited, value) then
            Util.PrintTable(value, prefix.."\t")
            visited[#visited+1] = value
        end
    end
    print(prefix.."}")
end
