
function string:startswith(str)
    return self:sub(1, #str) == str
end

function string:endswith(str)
    return str == "" or self:sub(-#str) == str
end

---Split an input string using a separator string.
---
---Found at https://stackoverflow.com/a/7615129
---@param sep string? # String to split by. Default is whitespace.
---@return string[]
function string:split(sep)
    if sep == nil then
        sep = '%s'
    end
    local t = {}
    for str in self:gmatch('([^'..sep..']+)') do
        table.insert(t, str)
    end
    return t
end
