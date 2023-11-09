--[[
    v1.6.0
    https://github.com/FrostSource/hla_extravaganza

    Debug utility functions.

    If not using `vscripts/core.lua`, load this file at game start using the following line:

    ```lua
    require "debug.core"
    ```

]]
require "util.globals"
require "extensions.entity"
require "math.common"

Debug = {}
Debug.version = "v1.6.0"

---
---
---Prints a formated indexed list of entities with custom property information.
---Also links children with their parents by displaying the index alongside the parent for easy look-up.
---
---    Debug.PrintEntityList(ents, {"getclassname", "getname", "getname"})
---
---If no properties are supplied the default properties are used: GetClassname, GetName, GetModelName
---If an empty property table is supplied only the base values are shown: Index, Handle, Parent
---Property patterns do not need to be functions.
---
---@param list EntityHandle[] # List of entities to print.
---@param properties string[] # List of property patterns to search for.
function Debug.PrintEntityList(list, properties)

    properties = properties or {"GetClassname", "GetName", "GetModelName"}

    local lenIndex  = 0
    local lenHandle = 0
    local lenParent = #"[none]"

    ---Values of the properties found in the entities
    ---@type any[][]
    local propertyValues = {}
    ---Metadata about the properties found matching the property patterns
    ---@type { name: string, func: function?, max: number }[]
    local propertyMetaData = {}

    ---@type string[]
    local headerNames = {"","Handle"}
    local headerSeparators = {"", "------"}
    headerNames[3 + #properties] = "Parent"
    headerSeparators[3 + #properties] = "------"

    ---@param e EntityHandle
    local function generate_parent_str(e)
        local parFormat = "%-"..lenIndex.."s %s, %s"
        local i = vlua.find(list, e)
        return parFormat:format("["..(i or "/").."]", string.gsub(tostring(e), "table: ", ""), e:GetClassname())
    end

    for index, ent in ipairs(list) do
        lenIndex  = max(lenIndex, #("["..index.."]") )
        lenHandle = max(lenHandle, #string.gsub(tostring(ent), "table: ", "") )
        if ent:GetMoveParent() then
            lenParent = max(lenParent, #generate_parent_str(ent:GetMoveParent()))
        end

        -- Create new property table for this entity
        propertyValues[index] = {}

        for propertyIndex, propertyName in ipairs(properties) do
            if propertyMetaData[propertyIndex] == nil then
                propertyMetaData[propertyIndex] = { name = propertyName, func = nil, max = #propertyName }
                headerNames[2 + propertyIndex] = propertyName
                headerSeparators[2 + propertyIndex] = string.rep("-", #propertyName)
            end
            local key, value = SearchEntity(ent, propertyName)
            -- Capture the first function matching the property pattern
            if key ~= nil and propertyMetaData[propertyIndex].func == nil then
                propertyMetaData[propertyIndex] = { name = key, func = value, max = #key }
                -- Add the name and separator for property to be unpacked later
                headerNames[2 + propertyIndex] = key
                headerSeparators[2 + propertyIndex] = string.rep("-", #key)
            end

            -- Find the value of the property
            ---@type any
            local foundValueInEntity = "nil"
            if propertyMetaData[propertyIndex] ~= nil then
                if type(propertyMetaData[propertyIndex].func) == "function" then
                    local s, result = pcall(propertyMetaData[propertyIndex].func, ent)
                    if s then
                        foundValueInEntity = result
                    end
                else
                    foundValueInEntity = ent[propertyName]
                end
            end

            propertyValues[index][propertyIndex] = tostring(foundValueInEntity)

            -- Track the biggest value length
            propertyMetaData[propertyIndex].max = max(propertyMetaData[propertyIndex].max, #tostring(foundValueInEntity))
        end
    end

    -- Create the format string with correct padding
    lenHandle = lenHandle + 1
    local formatStr   = "%-"..lenIndex.."s %-"..lenHandle.."s"
    for propertyIndex, propertyTable in ipairs(propertyMetaData) do
        formatStr = formatStr .. " | %-"..propertyTable.max.."s"
    end
    formatStr = formatStr .. " | %-"..lenParent.."s"

    print()
    print(string.format(formatStr,unpack(headerNames)))
    print(string.format(formatStr,unpack(headerSeparators)))
    for index, ent in ipairs(list) do
        local parent_str = ""
        if ent:GetMoveParent() then
            parent_str = generate_parent_str(ent:GetMoveParent())
        end

        propertyValues[index][#propertyValues[index]+1] = parent_str
        print(string.format(formatStr, "["..index.."]", string.gsub(tostring(ent), "table: ", ""), unpack(propertyValues[index]) ))
    end
    print()
end

---
---Prints information about all existing entities.
---
---@param properties? string[] # List of property patterns to search for when displaying entity information.
function Debug.PrintAllEntities(properties)
    properties = properties or {"GetClassname", "GetName", "GetModelName"}
    local list = {}
    local e = Entities:First()
    while e ~= nil do
        list[#list+1] = e
        e = Entities:Next(e)
    end
    Debug.PrintEntityList(list, properties)
end

---
---Print entities matching a search string.
---
---Searches name, classname and model name.
---
---@param search string # Search string, may include `*`.
---@param exact boolean # If the search should match exactly or part of the name.
---@param dont_include_parents boolean # Parents won't be included in the results.
---@param properties? string[] # List of property patterns to search for when displaying entity information.
function Debug.PrintEntities(search, exact, dont_include_parents, properties)
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
    Debug.PrintEntityList(ents, properties)
end

---
---Prints information about all entities within a sphere.
---
---@param origin Vector # Position to search for entities at.
---@param radius number # Max radius to find entities within.
---@param properties? string[] # List of property patterns to search for when displaying entity information.
function Debug.PrintAllEntitiesInSphere(origin, radius, properties)
    Debug.PrintEntityList(Entities:FindAllInSphere(origin, radius), properties)
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

local function printKeyValue(key, value, prefix)
    prefix = prefix or ""
    local vs = (type(value) == "string" and ("\"" .. tostring(value) .. "\"") or tostring(value))
    local ts = " ("..(IsEntity(value) and "entity" or type(value))..")"
    print( string.format( "\t%s%-32s %s", prefix, key, "= " .. format_string(vs) .. ts ) )
end

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
---@param meta? boolean # If meta tables should be printed.
function Debug.PrintTable(tbl, prefix, ignore, meta)
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
            printKeyValue(key, value, prefix)
            if type(value) == "table" and not IsEntity(value) and not vlua.find(ignore, value) then
                table.insert(ignore, value)
                current_recursion_level = current_recursion_level + 1
                Debug.PrintTable(value, prefix.."\t", ignore, meta)
                current_recursion_level = current_recursion_level - 1
            end
        end
    end
    if meta then
        local foundmeta = getmetatable(tbl)
        if foundmeta then
            print( string.format( "\t%s%-32s %s", prefix, "[#metatable]", "", "" ))
            table.insert(ignore, foundmeta)
            Debug.PrintTable(foundmeta, prefix.."\t", ignore, meta)
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
---Prints the keys/values of a table but not any tested tables.
---
---@param tbl table # Table to print.
function Debug.PrintTableShallow(tbl)
    if type(tbl) ~= "table" then return end
    print("{")
    for key, value in pairs(tbl) do
        printKeyValue(key, value)
    end
    print("}")
end

function Debug.PrintList(tbl, prefix)
    -- local ordered = {}
    -- local unordered = {}
    -- for _, value in ipairs(tbl) do
    --     ordered[#ordered+1] = value
    -- end
    -- for _, value in pairs(tbl) do
    --     if not vlua.find(ordered, value) then
    --         unordered[#unordered+1] = value
    --     end
    -- end
    -- local frmt = "%-"..(#tostring(#ordered)+1).."s %s"
    -- for index, value in ipairs(ordered) do
    --     print(frmt:format(index..".", value))
    -- end
    -- for _, value in ipairs(unordered) do
    --     print(frmt:format("*", value))
    -- end
    local m = 0
    prefix = prefix or ""
    for key, value in pairs(tbl) do
        m = max(m, #tostring(key)+1)
    end
    m = 0
    local frmt = "%"..m.."s  %s"
    for key, value in pairs(tbl) do
        if type(key) == "number" then
            print(prefix..frmt:format(key..".", value))
        else
            print(prefix..frmt:format(key, value))
        end
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
    if radius == 0 then radius = 16 end
    DebugDrawCircle(ent:GetOrigin(), Vector(255), 128, radius, true, duration)
    DebugDrawSphere(ent:GetCenter(), Vector(255), 128, radius, true, duration)
end
CBaseEntity.DebugFind = Debug.FindEntity

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
---Prints current context criteria for an entity except for values saved using `storage.lua`.
---
---@param ent EntityHandle
function Debug.PrintEntityBaseCriteria(ent)
    ---@type table<string, any>
    local c, d = {}, {}
    ent:GatherCriteria(c)
    for key, value in pairs(c) do
        if not key:find("::") then
            d[key] = value
        end
    end
    Debug.PrintTable(d)
end
CBaseEntity.PrintBaseCriteria = Debug.PrintEntityBaseCriteria

local classes = {
    [CBaseEntity] = 'CBaseEntity';
    [CAI_BaseNPC] = 'CAI_BaseNPC';
    [CBaseAnimating] = 'CBaseAnimating';
    [CBaseCombatCharacter] = 'CBaseCombatCharacter';
    [CBaseFlex] = 'CBaseFlex';
    [CBaseModelEntity] = 'CBaseModelEntity';
    [CBasePlayer] = 'CBasePlayer';
    [CBaseTrigger]='CBaseTrigger';
    [CBodyComponent] = 'CBodyComponent';
    [CEntityInstance] = 'CEntityInstance';
    [CEnvEntityMaker] = 'CEnvEntityMaker';
    [CEnvProjectedTexture] = 'CEnvProjectedTexture';
    [CEnvTimeOfDay2] = 'CEnvTimeOfDay2';
    [CHL2_Player] = 'CHL2_Player';
    [CInfoData] = 'CInfoData';
    [CInfoWorldLayer] = 'CInfoWorldLayer';
    [CLogicRelay] = 'CLogicRelay';
    [CMarkupVolumeTagged] = 'CMarkupVolumeTagged';
    [CPhysicsProp] = 'CPhysicsProp';
    [CPointClientUIWorldPanel] = 'CPointClientUIWorldPanel';
    [CPointTemplate] = 'CPointTemplate';
    [CPointWorldText] = 'CPointWorldText';
    [CPropHMDAvatar] = 'CPropHMDAvatar';
    [CPropVRHand] = 'CPropVRHand';
    [CSceneEntity] = 'CSceneEntity';
    [CScriptKeyValues] = 'CScriptKeyValues';
    [CScriptPrecacheContext] = 'CScriptPrecacheContext';
}

function Debug.GetClassname(ent)
    return classes[ent] or "none"
end

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

---
---Returns a simplified vector string with decimal places truncated.
---
---@param vector Vector
---@return string
function Debug.SimpleVector(vector)
    return "[" .. math.trunc(vector.x, 3) .. " " .. math.trunc(vector.y, 3) .. " " .. math.trunc(vector.z, 3) .. "]"
end

---
---Draw a simple sphere without worrying about all the properties.
---
---@param x number
---@param y number
---@param z number
---@param radius? number
---@overload fun(pos: Vector, radius?: number)
function Debug.Sphere(x, y, z, radius)
    if IsVector(x) then
        ---@diagnostic disable-next-line: cast-type-mismatch
        ---@cast x Vector
        radius = y
        z = x.z
        y = x.y
        x = x.x
    end

    radius = radius or 8

    DebugDrawSphere(Vector(x, y, z), Vector(255, 255, 255), 255, radius, false, 10)
end