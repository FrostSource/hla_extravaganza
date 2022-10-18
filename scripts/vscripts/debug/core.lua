--[[
    v1.1.0
    https://github.com/FrostSource/hla_extravaganza

    Debug utility functions.

    Load this file at game start using the following line:

        require "debug.core"

]]
Debug = {}

---Prints useful entity information about a list of entities, such as classname and model.
---@param list EntityHandle[]
function Debug.PrintEntityList(list)

    local len_index  = 0
    local len_handle = 0
    local len_class  = 0
    local len_name   = 0
    local len_model  = 0
    local len_parent = #"[none]"

    ---comment
    ---@param e EntityHandle
    local function generate_parent_str(e)
        local par_format = "%-"..len_index.."s %s, %s"
        local i = vlua.find(list, e)
        return par_format:format("["..(i or "/").."]", tostring(e), e:GetClassname())
        -- "("..tostring(ent:GetMoveParent())..", "..ent:GetMoveParent():GetClassname()..")"
    end

    for index, ent in ipairs(list) do
        len_index  = max(len_index, #("["..index.."]") )
        len_handle = max(len_handle, #tostring(ent) )
        len_class  = max(len_class, #ent:GetClassname() )
        len_name   = max(len_name, #ent:GetName() )
        len_model  = max(len_model, #ent:GetModelName() )
        if ent:GetMoveParent() then
            len_parent = max(len_parent, #generate_parent_str(ent:GetMoveParent()))
        end
    end
    len_handle = len_handle + 1
    local format_str_header = "     %-"..len_handle.."s %-"..len_class.."s %-"..len_name.."s %-"..len_model.."s %-"..len_parent.."s"
    local format_str_item   = "%-"..len_index.."s %-"..len_handle.."s %-"..len_class.."s %-"..len_name.."s %-"..len_model.."s %-"..len_parent.."s"

    print()
    print(string.format(format_str_item,"","Handle", "Classname:", "Name:", "Model Name:", "Parent"))
    print(string.format(format_str_item,"", "------", "----------", "-----", "-----------", "------"))
    for index, ent in ipairs(list) do
        local parent_str = ""
        if ent:GetMoveParent() then
            parent_str = generate_parent_str(ent:GetMoveParent())
        end
        print(string.format(format_str_item, "["..index.."]", ent, ent:GetClassname(), ent:GetName(), ent:GetModelName(), parent_str ))
    end
    print()


    -- print(string.format("\n%-12s %-40s %-40s %-40s %-60s","Handle", "Classname:", "Name:", "Model Name:", "Parent"))
    -- print(string.format("%-12s %-40s %-40s %-40s %-60s",  "------", "----------", "-----", "-----------", "------------"))
    -- for _, ent in ipairs(list) do
    --     print(string.format("%-12s %-40s %-40s %-40s %-60s", ent, ent:GetClassname(), ent:GetName(), ent:GetModelName(), ent:GetMoveParent() and ent:GetMoveParent():GetClassname() or "" ))
    -- end
    -- print()
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

---Print entities matching a search string.
---
---Searches name, classname and model name.
---@param search string
---@param exact boolean # If the search should match exactly or part of the name.
---@param dont_include_parents boolean # Parents won't be included in the results.
function Debug.PrintEntities(search, exact, dont_include_parents)
    if not exact then
        search = "*"..search.."*"
    end

    -- Get all matching ents
    local preents = {}
    for _, list in ipairs({
        Entities:FindAllByName(search),
        Entities:FindAllByClassname(search),
        Entities:FindAllByModel(search)
    }) do
        for _, value in ipairs(list) do
            preents[#preents+1] = value
            if not dont_include_parents then
                vlua.extend(preents, Debug.GetParents(value))
            end
        end
    end
    -- Filter duplicates
    local ents = {}
    for _, ent in pairs(preents) do
        if not vlua.find(ents, ent) then
            ents[#ents+1] = ent
        end
    end
    Debug.PrintEntityList(ents)
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
        print( string.format( "\t%s%-32s %s", prefix, key, "= " .. (type(value) == "string" and ("\"" .. tostring(value) .. "\"") or tostring(value)) .. " ("..(IsEntity(value) and "entity" or type(value))..")" ) )
        if type(value) == "table" and not vlua.find(visited, value) and not IsEntity(value) then
            Debug.PrintTable(value, prefix.."\t")
            visited[#visited+1] = value
        end
    end
    print(prefix.."}")
end

---Draws a debug line to an entity in game.
---@param ent EntityHandle|string # Handle or targetname of the entity(s) to find.
---@param duration number?
function Debug.FindEntity(ent, duration)
    duration = duration or 20
    if type(ent) == "string" then
        local ents = Entities:FindAllByName(ent)
        for _,e in ipairs(ents) do
            Debug.FindEntity(e)
        end
        return
    end
    local from = Vector()
    if Entities:GetLocalPlayer() then
        from = Entities:GetLocalPlayer():EyePosition()
    end
    DebugDrawLine(from, ent:GetOrigin(), 255, 0, 0, true, duration)
    local radius = ent:GetBiggestBounding()/2
    print(radius)
    if radius == 0 then radius = 16 end
    DebugDrawCircle(ent:GetOrigin(), Vector(255), 128, radius, true, duration)
    DebugDrawSphere(ent:GetCenter(), Vector(255), 128, radius, true, duration)
end
function CBaseEntity:DebugFind(duration)
    Debug.FindEntity(self, duration)
end

---comment
---@param ent EntityHandle
function Debug.PrintEntityCriteria(ent)
    local c = {}
    ent:GatherCriteria(c)
    Debug.PrintTable(c)
end
function CBaseEntity:PrintCriteria()
    Debug.PrintEntityCriteria(self)
end

