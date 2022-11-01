--[[
    v1.3.0
    https://github.com/FrostSource/hla_extravaganza

    Debug utility functions.

    If not using `vscripts/core.lua`, load this file at game start using the following line:

    ```lua
    require "debug.core"
    ```

]]
Debug = {}

---
---Prints useful entity information about a list of entities, such as classname and model.
---
---@param list EntityHandle[]
function Debug.PrintEntityList(list)

    local len_index  = 0
    local len_handle = 0
    local len_class  = 0
    local len_name   = 0
    local len_model  = 0
    local len_parent = #"[none]"

    ---@param e EntityHandle
    local function generate_parent_str(e)
        local par_format = "%-"..len_index.."s %s, %s"
        local i = vlua.find(list, e)
        return par_format:format("["..(i or "/").."]", tostring(e), e:GetClassname())
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
    local format_str   = "%-"..len_index.."s %-"..len_handle.."s %-"..len_class.."s %-"..len_name.."s %-"..len_model.."s %-"..len_parent.."s"

    print()
    print(string.format(format_str,"","Handle", "Classname:", "Name:", "Model Name:", "Parent"))
    print(string.format(format_str,"", "------", "----------", "-----", "-----------", "------"))
    for index, ent in ipairs(list) do
        local parent_str = ""
        if ent:GetMoveParent() then
            parent_str = generate_parent_str(ent:GetMoveParent())
        end
        print(string.format(format_str, "["..index.."]", ent, ent:GetClassname(), ent:GetName(), ent:GetModelName(), parent_str ))
    end
    print()
end

---
---Prints information about all existing entities.
---
function Debug.PrintAllEntities()
    local list = {}
    local e = Entities:First()
    while e ~= nil do
        list[#list+1] = e
        e = Entities:Next(e)
    end
    Debug.PrintEntityList(list)
end

---
---Print entities matching a search string.
---
---Searches name, classname and model name.
---
---@param search string # Search string, may include `*`.
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
                vlua.extend(preents, value:GetParents())
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

---Turns newlines into spaces.
---@param str string
local function format_string(str)
    str = str:gsub('\n',' ')
    return str
end

---If 'FDesc' key should be be ignored in printed tables.
local ignore_fdesc = true
---Maximum number of keys Debug.PrintTable can print before force exiting.
local bailout_count = 9000

-- Used in Debug.PrintTable
local current_recursion_level = 0
local current_print_count = 0

-- local function table_level(level, count, m)
--     local tbl = {}
--     local val
--     m = m or level
--     for i = 1, count do
--         if level == 0 then
--             val = RandomFloat(0,10000)
--         else
--             val = table_level(level - 1, count, m)
--         end
--         tbl[DoUniqueString("level"..(m - level))] = val
--     end
--     return tbl
-- end
-- local test_table = table_level(5, 10)

---
---Prints the keys/values of a table and any tested tables.
---
---This is different from `DeepPrintTable` in that it will not print members of entity handles.
---
---@param tbl table # Table to print.
---@param prefix? string # Optional prefix for each line.
---@param ignore? any[] # Optional nested tables to ignore.
function Debug.PrintTable(tbl, prefix, ignore)
    if type(tbl) ~= "table" then return end
    prefix = prefix or ""
    ignore = ignore or {tbl}
    print(prefix.."{")
    for key, value in pairs(tbl) do
        -- Return up a level
        if current_print_count >= bailout_count or current_print_count == -1 then
            if current_print_count >= bailout_count then
                print("!! Debug.PrintTable bailing out after "..current_print_count.." occurrences! current_recursion_level = "..current_recursion_level)
                current_print_count = -1
            end
            if current_recursion_level == 0 then break end
            return
        end
        if not ignore_fdesc or key ~= "FDesc" then
            current_print_count = current_print_count + 1
            local vs = (type(value) == "string" and ("\"" .. tostring(value) .. "\"") or tostring(value))
            local ts = " ("..(IsEntity(value) and "entity" or type(value))..")"
            print( string.format( "\t%s%-32s %s", prefix, key, "= " .. format_string(vs) .. ts ) )
            if type(value) == "table" and not IsEntity(value) and not vlua.find(ignore, value) then
                ignore[#ignore+1] = value
                current_recursion_level = current_recursion_level + 1
                Debug.PrintTable(value, prefix.."\t", ignore)
                current_recursion_level = current_recursion_level - 1
            end
        end
    end
    if current_print_count ~= -1 then
        print(prefix.."}")
    end
    if current_recursion_level <= 0 then
        current_recursion_level = 0
        current_print_count = 0
    end
end

---
---Draws a debug line to an entity in game.
---
---@param ent EntityHandle|string # Handle or targetname of the entity(s) to find.
---@param duration number? # Number of seconds the debug should display for.
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

---
---Prints all current context criteria for an entity.
---
---@param ent EntityHandle
function Debug.PrintEntityCriteria(ent)
    local c = {}
    ent:GatherCriteria(c)
    Debug.PrintTable(c)
end
CBaseEntity.PrintCriteria = Debug.PrintEntityCriteria

---
---Prints a visual ASCII graph showing the distribution of values between a min/max bound.
---
---E.g.
---
---    Debug.PrintGraph(6, 0, 1, {
---        val1 = RandomFloat(0, 1),
---        val2 = RandomFloat(0, 1),
---        val3 = RandomFloat(0, 1)
---    })
---    ->
---    1^ []        
---     | []    []  
---     | [] [] []  
---     | [] [] []  
---     | [] [] []  
---    0 ---------->
---       v  v  v   
---       a  a  a   
---       l  l  l   
---       3  1  2   
---    val3 = 0.96067351102829
---    val1 = 0.5374761223793
---    val2 = 0.7315416932106
---
---@param height integer # Height of the actual graph in print rows. Heigher values give more accurate results but can overflow the console making it hard to read.
---@param min_val? number # Minimum expected value for `name_value_pairs`. Default is `0`.
---@param max_val? number # Maxmimum expected value for `name_value_pairs`. Default is `1`.
---@param name_value_pairs table<string,number> # Values to visualize on the graph.
function Debug.PrintGraph(height, min_val, max_val, name_value_pairs)
    height = height or 10
    min_val = min_val or 0
    max_val = max_val or 1
    local values = name_value_pairs
    local max_name_height = 0
    local max_gutter = max(#tostring(min_val), #tostring(max_val))
    for name in pairs(values) do
        max_name_height = max(max_name_height, #name)
    end

    ---@type string[]
    local text_rows = {}
    ---Returns a new string from a non existing key
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
    local i = 0
    for name, value in pairs(values) do
        i = i + 1
        -- ceil so if above lowest bound, at least show something
        local top = math.ceil(RemapValClamped(value, min_val, max_val, 0, height-1))
        print(top)
        -- first half with name
        add_column(repeat_char(" ", height-1-top), repeat_char("[", top), "-", str_to_chars(name), repeat_char(" ", max_name_height-#name))
        -- second half to complete graph line
        add_column(repeat_char(" ", height-top-1), repeat_char("]", top), "-", repeat_char(" ", max_name_height))
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
    for name, value in pairs(values) do
        print(name .. " = " .. value)
    end
    print()
end

local classes = {
    [CBaseEntity] = 'CBaseEntity',
    [CAI_BaseNPC] = 'CAI_BaseNPC',
    [CBaseAnimating] = 'CBaseAnimating',
    [CBaseCombatCharacter] = 'CBaseCombatCharacter',
    [CBaseFlex] = 'CBaseFlex',
    [CBaseModelEntity] = 'CBaseModelEntity',
    [CBasePlayer] = 'CBasePlayer',
    [CBaseTrigger]='CBaseTrigger',
    [CBodyComponent] = 'CBodyComponent',
    [CEntityInstance] = 'CEntityInstance',
    [CEnvEntityMaker] = 'CEnvEntityMaker',
    [CEnvProjectedTexture] = 'CEnvProjectedTexture',
    [CEnvTimeOfDay2] = 'CEnvTimeOfDay2',
    [CHL2_Player] = 'CHL2_Player',
    [CInfoData] = 'CInfoData',
    [CInfoWorldLayer] = 'CInfoWorldLayer',
    [CLogicRelay] = 'CLogicRelay',
    [CMarkupVolumeTagged] = 'CMarkupVolumeTagged',
    [CPhysicsProp] = 'CPhysicsProp',
    [CPointClientUIWorldPanel] = 'CPointClientUIWorldPanel',
    [CPointTemplate] = 'CPointTemplate',
    [CPointWorldText] = 'CPointWorldText',
    [CPropHMDAvatar] = 'CPropHMDAvatar',
    [CPropVRHand] = 'CPropVRHand',
    [CSceneEntity] = 'CSceneEntity',
    [CScriptKeyValues] = 'CScriptKeyValues',
    [CScriptPrecacheContext] = 'CScriptPrecacheContext',
    [CTakeDamageInfo] = 'CTakeDamageInfo',
}

---
---Prints a nested list of entity inheritance.
---
---@param ent EntityHandle
function Debug.PrintInheritance(ent)
    print(ent:GetClassname() .. " -> " .. tostring(ent))
    local parent = getmetatable(ent)
    local new_parent = nil
    local prefix = "  "
    while parent ~= nil do
        print(prefix .. (classes[parent.__index] or "[no class name]") .. " -> " .. tostring(parent) .. "(__index:" .. tostring(parent.__index) .. ")")
        if parent.__index ~= nil and parent.__index ~= parent then
            new_parent = getmetatable(parent.__index)
        else
            new_parent = getmetatable(parent)
        end
        if new_parent == parent then
            break
        end
        parent = new_parent
        prefix = prefix .. "  "
    end
end
