--[[
    v1.0.0
    Prefab specific functions for prefabs/logic/player_extension/logic_player_extension.vmap
]]
require "util.player"

---Sets the item held by player's left hand as the activator in the IO chain.
---@param data TypeIOInvoke
local function GetHeldLeftHand(data)
    DoEntFire(thisEntity:GetName().."_get_held_item", "FireUser1", "", 0, Player.LeftHand.ItemHeld or Player.LeftHand or Player, data.caller)
end

--Sets the item held by player's right hand as the activator in the IO chain.
---@param data TypeIOInvoke
local function GetHeldRightHand(data)
    DoEntFire(thisEntity:GetName().."_get_held_item", "FireUser2", "", 0, Player.RightHand.ItemHeld or Player.RightHand or Player, data.caller)
end

---Sets the item held by player's primary hand as the activator in the IO chain.
---@param data TypeIOInvoke
local function GetHeldPrimaryHand(data)
    DoEntFire(thisEntity:GetName().."_get_held_item", "FireUser3", "", 0, Player.PrimaryHand.ItemHeld or Player.PrimaryHand or Player, data.caller)
end

--Sets the item held by player's secondary hand as the activator in the IO chain.
---@param data TypeIOInvoke
local function GetHeldSecondaryHand(data)
    DoEntFire(thisEntity:GetName().."_get_held_item", "FireUser4", "", 0, Player.SecondaryHand.ItemHeld or Player.SecondaryHand or Player, data.caller)
end

-- Add local functions to private script scope to avoid environment pollution.
local _a,_b=1,thisEntity:GetPrivateScriptScope()while true do local _c,_d=debug.getlocal(1,_a)if _c==nil then break end;if type(_d)=='function'then _b[_c]=_d end;_a=1+_a end
