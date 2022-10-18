--[[
    v1.1.0
    https://github.com/FrostSource/hla_extravaganza

    Provides string class extension methods.
]]

---
---Gets if a string starts with a substring.
---
---@param substr string
---@return boolean
function string:startswith(substr)
    return self:sub(1, #substr) == substr
end

---
---Gets if a string ends with a substring.
---
---@param substr string
---@return boolean
function string:endswith(substr)
    return substr == "" or self:sub(-#substr) == substr
end

---
---Split an input string using a separator string.
---
---Found at https://stackoverflow.com/a/7615129
---
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

---
---Truncates a string to a maximum length.
---If the string is shorter than `len` the original string is returned.
---
---@param len integer # Maximum length the string can be.
---@param replacement? string # Suffix for long strings. Default is '...'
---@return string
function string:truncate(len, replacement)
    replacement = replacement or "..."
    if #self > len then
        return self:sub(1, len - #replacement) .. replacement
    end
    return tostring(self)
end
