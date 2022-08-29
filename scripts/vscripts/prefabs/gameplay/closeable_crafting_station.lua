--[[
    v1.0.0
    https://github.com/FrostSource/hla_extravaganza

    This script fires outputs to a logic_case based on animation tags.
    It is not directly attached to any entity because it is minified
    first and embedded in the prefab to make prefab sharing easier.

    This script is just for debug purposes and does not need to be copied!
]]
local n = Entities:FindByName(nil,thisEntity:GetName()..'_outputs')
local function AnimTagListener( sTagName, nStatus )
	-- print( ' AnimTag: ', sTagName, ' Status: ', nStatus )
    if sTagName == 'Interface Deploy Done' and nStatus == 1 then
        --print('OnConsoleStartedOpening')
        n:FireOutput('OnCase01', thisEntity, thisEntity, nil, 0)
    elseif sTagName == 'Interface Deploy Done' and nStatus == 2 then
        -- print('OnConsoleScreenOpened')
        n:FireOutput('OnCase02', thisEntity, thisEntity, nil, 0)
    elseif sTagName == 'Bootup Done' and nStatus == 1 then
        -- print('OnCradleStartedOpening')
        n:FireOutput('OnCase03', thisEntity, thisEntity, nil, 0)
    elseif sTagName == 'Bootup Done' and nStatus == 2 then
        -- print('OnCradleFinishedOpening')
        n:FireOutput('OnCase04', thisEntity, thisEntity, nil, 0)
    elseif sTagName == 'Tray Movement Done' and nStatus == 1 then
        -- print('OnTrayInteraction')
        n:FireOutput('OnCase05', thisEntity, thisEntity, nil, 0)
    elseif sTagName == 'Trays Retracted' and nStatus == 1 then
        -- print('OnResinFinished')
        n:FireOutput('OnCase06', thisEntity, thisEntity, nil, 0)
    elseif sTagName == 'Upgrade Done' and nStatus == 1 then
        -- print('OnUpgradeStarted')
        n:FireOutput('OnCase07', thisEntity, thisEntity, nil, 0)
    elseif sTagName == 'Upgrade Done' and nStatus == 2 then
        -- print('OnUpgradeFinished')
        n:FireOutput('OnCase08', thisEntity, thisEntity, nil, 0)
    elseif sTagName == 'Crafting Done' and nStatus == 2 then
        -- print('OnWeaponReady')
        n:FireOutput('OnCase09', thisEntity, thisEntity, nil, 0)
    end
end

-- This code is executed via logic_auto so all needed entities should exist by this point.
Entities:FindByClassnameNearest('prop_hlvr_crafting_station_console', thisEntity:GetOrigin(),16):RegisterAnimTagListener( AnimTagListener )
