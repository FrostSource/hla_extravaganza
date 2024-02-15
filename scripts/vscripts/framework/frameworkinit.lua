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
    -- If Scalable Init Support workshop addon is enabled, don't run this code.
    -- Follow instructions below for init file naming standards.
    --
    -- If game is running in tools mode we will require even if Scalable Init Support is enabled
    -- because it does not work even when displayed as enabled.
    --
    if not Convars:GetStr("default_enabled_addons_list"):find("2182586257") or IsInToolsMode() then
        -- This is a direct copy of Scalable Init Support gameinit.lua for compatibility.
        -- It hasn't been updated since Mar 28, 2021 so it should be safe to use a copy without
        -- worrying about changes.
        -- This file allows for scalable expansion of multiple custom init files from multiple different addons to be active at once

        -- Your final custom init file should exist at the path: "scripts/vscripts/mods/init/<YOUR_WORKSHOP_ID>.lua" - Update with this naming standard once your workshop addon has been initially submitted.
        -- For functionality during development, your custom init path should be: "Half-Life Alyx/game/hlvr_addons/<YOUR_ADDON_NAME>/scripts/vscripts/mods/init/<YOUR_ADDON_NAME>.lua", and you should ensure Scalable Init Support is enabled.

        local DIRECTORIES = {
            "mods/init/",
            ""
        }

        local addonList = Convars:GetStr("default_enabled_addons_list")--[[@as string]]

        print("Searching scripts for enabled addon workshop IDs...")
        for workshopID in addonList:gmatch("[^,]+") do

            for _, DIRECTORY in pairs(DIRECTORIES) do

                local path = DIRECTORY .. workshopID

                xpcall(function()
                    require(path)
                    print("Executed " .. path .. ".lua")
                end,
                function(errorMessage)
                    if not errorMessage:find(path .. "\']Failed to find") then
                        warn("Error loading " .. path .. ":\n" .. errorMessage)
                    end
                end )
            end

        end
    end
end