
if IsServer() then
    local success, result = pcall(require, "core")
    if not success then
        Warning("core.lua failed to initialized\n")
        Warning(tostring(result).."\n")
    end
end