--[[
    v2.0.0
    https://github.com/FrostSource/hla_extravaganza

    Used to automatically load `core` and any addon scripts.

    Checks if Scalable init Support is enabled before requiring specific addon scripts.
]]

if IsServer() then
    local success, result = pcall(require, "core")
    if not success then
        Warning("core.lua failed to initialized\n")
        Warning(tostring(result).."\n")
    end

    --
    -- If Scalable Init Support is enabled, don't require these addon scripts
    -- Instead the `mods/init/` folder should be supported.
    --
    -- If game is running in tools mode we will require even if Scalable Init Support is enabled
    -- because it does not work even when displayed as enabled
    --
    if not Convars:GetStr("default_enabled_addons_list"):find("2182586257") or IsInToolsMode() then
        -- Add requires here
    end
end