--[[
    v1.0.0
    Prefab specific functions for prefabs/logic/player_extension/logic_player_extension.vmap
]]
require "util.player"

---Passes the item held by player's left hand as the activator in the IO chain.
---@param data TypeIOInvoke
local function GetHeldLeftHand(data)
    DoEntFireByInstanceHandle(thisEntity, "FireUser1", "", 0, Player.LeftHand.ItemHeld or Player.LeftHand or Player, data.caller)
    -- DoEntFire("test_player", "FireUser1", "", 0, Player.LeftHand.ItemHeld or Player.LeftHand or Player, data.caller)
end

--Passes the item held by player's right hand as the activator in the IO chain.
---@param data TypeIOInvoke
local function GetHeldRightHand(data)
    DoEntFireByInstanceHandle(thisEntity, "FireUser2", "", 0, Player.RightHand.ItemHeld or Player.RightHand or Player, data.caller)
    -- DoEntFire("test_player", "FireUser1", "", 0, Player.RightHand.ItemHeld or Player.RightHand or Player, data.caller)
end

-- Add local functions to private script scope to avoid environment pollution.
local _a,_b=1,thisEntity:GetPrivateScriptScope()while true do local _c,_d=debug.getlocal(1,_a)if _c==nil then break end;if type(_d)=='function'then _b[_c]=_d end;_a=1+_a end
