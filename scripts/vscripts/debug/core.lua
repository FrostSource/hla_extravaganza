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
    if type(tbl) ~= "table" then return end
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

-- local function add_column(...)

function Debug.PrintGraph(height, min_val, max_val, name_value_pairs)
    height = height or 10
    min_val = min_val or 0
    max_val = max_val or 1
    local values = name_value_pairs
    local max_name_height = 0
    local max_gutter = max(#tostring(min_val), #tostring(max_val))
    for i = 1, #values, 2 do
        max_name_height = max(max_name_height, #values[i])
    end

    ---@type string[]
    local text_rows = {}
    text_rows.__index = function (table, key)
        return ""
    end
    setmetatable(text_rows, text_rows)

    local function repeat_char(s, n)
        local strs = {}
        for i = 1, n do
            strs[#strs+1] = s
        end
        return strs
    end

    ---Flatten any nested string arrays into one array
    ---@param tbl (string|string[])[]
    ---@return string[]
    local function flatten_table(tbl)
        local flattened = {}
        for _, value in ipairs(tbl) do
            if type(value) == "table" then
                vlua.extend(flattened, flatten_table(value))
            else
                flattened[#flattened+1] = value
            end
        end
        return flattened
    end

    ---Add a list of chars downwards
    ---@param ... string|string[]
    local function add_column(...)
        local args = {...}
        ---@type string[]
        local strs = {}

        -- Collect all arrays and strings into one string array
        for index, arg in ipairs(args) do
            if type(arg) == "table" then
                vlua.extend(strs, flatten_table(arg))
            else
                strs[#strs+1] = arg
            end
        end

        -- Append all strings downwards
        for i, value in ipairs(strs) do
            text_rows[i] = text_rows[i] .. value
        end
    end

    ---Turns a string into an array of chars
    ---@param s string
    ---@return string[]
    local function str_to_chars(s)
        local strs = {}
        for i = 1, #s do
            strs[#strs+1] = s:sub(i,i)
        end
        return strs
    end

    -- gutter numbers
    local gutter_format = "%"..max_gutter.."s"
    local max_val_str = gutter_format:format(max_val)
    local min_val_str = gutter_format:format(min_val)
    for i = 1, max_gutter do
        local top = tostring(max_val_str):sub(i,i)
        if top == "" then top = " " end
        local bot = tostring(min_val_str):sub(i,i)
        if bot == "" then bot = " " end
        add_column(top, repeat_char(" ", height-2), bot, repeat_char(" ", max_name_height))
    end
    -- Y line
    add_column("^", repeat_char("|", height-2), " ", repeat_char(" ", max_name_height))
    -- Space before first value
    add_column(repeat_char(" ", height-1), "-", repeat_char(" ", max_name_height))
    -- Values
    local separate_names = false
    for i = 1, #values, 2 do
        local name,value = values[i], values[i+1]
        -- ceil so if above lowest bound, at least show something
        local top = math.ceil(RemapValClamped(value, min_val, max_val, 0, height-1))
        print(top)
        -- first half with name
        add_column(repeat_char(" ", height-1-top), repeat_char("[", top), "-", str_to_chars(name), repeat_char(" ", max_name_height-#name))
        -- add_column(repeat_char("e", height-1), "-", str_to_chars(name))
        -- second half to complete graph line
        add_column(repeat_char(" ", height-top-1), repeat_char("]", top), "-", repeat_char(" ", max_name_height))
        -- add_column(repeat_char("g", height-1), "-", repeat_char(" ", max_name_height))
        -- space between values
        if separate_names and i < #values-1 then
            add_column(repeat_char(" ", height-1), "-", repeat_char("|", max_name_height))
        else
            add_column(repeat_char(" ", height-1), "-", repeat_char(" ", max_name_height))
        end
    end
    -- Finish X line
    add_column(repeat_char(" ", height-1), ">", repeat_char(" ", max_name_height))

    print()
    for _, text_row in ipairs(text_rows) do
        print(text_row)
    end
    print()
end
