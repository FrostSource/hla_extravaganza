--[[
    v1.1.0
    https://github.com/FrostSource/hla_extravaganza

    The core math extension script.

    If not using `vscripts/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "math.core"
    ```
]]

local version = "v1.1.0"

---
---Get the sign of a number.
---
---@param x number # The input number.
---@return 1|0|-1 # Returns 1 if the number is positive, -1 if the number is negative, or 0 if the number is zero.
function math.sign(x)
    return x > 0 and 1 or (x < 0 and -1 or 0)
end

---
---Truncates a number to the specified number of decimal places.
---
---@param number number # The input number.The input number.
---@param places integer # The number of decimal places to keep.
---@return number #  The input number truncated to the specified decimal places.
function math.trunc(number, places)
    local shift = 10 ^ places
    return math.floor(number * shift) / shift
end

---
---Rounds a number to the specified number of decimal places.
---
---@param number number # The input number to be rounded.
---@param decimals? integer # The number of decimal places to round to. If not provided, the number will be rounded to the nearest whole number.
---@return number # The input number rounded to the specified decimal places or nearest whole number.
function math.round(number, decimals)
    local shift = 10 ^ (decimals or 0)
    return math.floor(number * shift + 0.5) / shift
end

return version