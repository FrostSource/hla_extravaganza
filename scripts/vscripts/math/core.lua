--[[
    v1.0.0
    https://github.com/FrostSource/hla_extravaganza

    The core math extension script.
]]

---Get the sign of a number.
---@param x number
---@return 1|0|-1
function math.sign(x)
    return x > 0 and 1 or (x < 0 and -1 or 0)
end