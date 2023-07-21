--[[
    v1.2.0
    https://github.com/FrostSource/hla_extravaganza

    Provides string class extension methods.

    If not using `vscripts/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "extensions.string"
    ```
]]

local version = "v1.2.0"

---
---Gets if a string starts with a substring.
---@param s string
---@param substr string
---@return boolean
function string.startswith(s, substr)
    return s:sub(1, #substr) == substr
end

---
---Gets if a string ends with a substring.
---
---@param s string
---@param substr string
---@return boolean
function string.endswith(s, substr)
    return substr == "" or s:sub(-#substr) == substr
end

---
---Split an input string using a separator string.
---
---Found at https://stackoverflow.com/a/7615129
---
---@param s string
---@param sep string? # String to split by. Default is whitespace.
---@return string[]
function string.split(s, sep)
    if sep == nil then
        sep = '%s'
    end
    local t = {}
    for str in s:gmatch('([^'..sep..']+)') do
        table.insert(t, str)
    end
    return t
end

---
---Truncates a string to a maximum length.
---If the string is shorter than `len` the original string is returned.
---
---@param s string
---@param len integer # Maximum length the string can be.
---@param replacement? string # Suffix for long strings. Default is '...'
---@return string
function string.truncate(s, len, replacement)
    replacement = replacement or "..."
    if #s > len then
        return s:sub(1, len - #replacement) .. replacement
    end
    return tostring(s)
end

---
---Trims characters from the left side of the string up to the last occurrence of a specified character.
---
---@param s string
---@param char string # The character to trim the string at the last occurrence.
---@return string # The trimmed string.
function string.trimleft(s, char)
    local index = s:match(".*" .. char .. "()")
    return index and s:sub(index) or s
end

---
---Trims characters from the right side of the string up to the last occurrence of a specified character.
---
---@param s string
---@param char string # The character to trim the string at the last occurrence.
---@return string # The trimmed string.
function string.trimright(s, char)
    local index = s:find(char)
    return index and s:sub(1, index - 1) or s
end

