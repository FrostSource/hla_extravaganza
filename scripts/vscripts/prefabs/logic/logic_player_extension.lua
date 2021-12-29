--[[
    v1.0.0
    Prefab specific functions for prefabs/logic/player_extension/logic_player_extension.vmap
]]
require "util.player"

------------------------
-- Getting Held Items --
------------------------

---Sets the item held by player's left hand as the activator in the IO chain.
---@param data TypeIOInvoke
local function GetHeldLeftHand(data)
    DoEntFire(thisEntity:GetName().."_get_held_item", "FireUser1", "", 0, Player.LeftHand.ItemHeld or Player.LeftHand or Player, thisEntity)
end
---Sets the item held by player's right hand as the activator in the IO chain.
---@param data TypeIOInvoke
local function GetHeldRightHand(data)
    DoEntFire(thisEntity:GetName().."_get_held_item", "FireUser2", "", 0, Player.RightHand.ItemHeld or Player.RightHand or Player, thisEntity)
end
---Sets the item held by player's primary hand as the activator in the IO chain.
---@param data TypeIOInvoke
local function GetHeldPrimaryHand(data)
    DoEntFire(thisEntity:GetName().."_get_held_item", "FireUser3", "", 0, Player.PrimaryHand.ItemHeld or Player.PrimaryHand or Player, thisEntity)
end
---Sets the item held by player's secondary hand as the activator in the IO chain.
---@param data TypeIOInvoke
local function GetHeldSecondaryHand(data)
    DoEntFire(thisEntity:GetName().."_get_held_item", "FireUser4", "", 0, Player.SecondaryHand.ItemHeld or Player.SecondaryHand or Player, thisEntity)
end

--------------------------
-- Getting Items Stored --
--------------------------

-- ---Gets the number of energygun magazines stored in the backpack.
-- ---@param data TypeIOInvoke
-- local function GetAmmoEnergygun(data)
--     -- DoEntFire(thisEntity:GetName().."_get_ammo", "FireUser1", tostring(Player.Items.ammo.energygun), 0, data.activator, thisEntity)
--     local e = Entities:FindByName(nil, thisEntity:GetName().."_get_ammo")
--     e:FireOutput("OnUser1", data.activator, e, {}, 0)
-- end
-- ---Gets the number of shotgun magazines stored in the backpack.
-- ---@param data TypeIOInvoke
-- local function GetAmmoShotgun(data)
--     DoEntFire(thisEntity:GetName().."_get_ammo", "FireUser2", tostring(Player.Items.ammo.rapidfire), 0, data.activator, thisEntity)
-- end
-- ---Gets the number of rapidfire magazines stored in the backpack.
-- ---@param data TypeIOInvoke
-- local function GetAmmoRapidfire(data)
--     DoEntFire(thisEntity:GetName().."_get_ammo", "FireUser3", tostring(Player.Items.ammo.shotgun), 0, data.activator, thisEntity)
-- end
-- ---Gets the number of energygun magazines stored in the backpack.
-- ---@param data TypeIOInvoke
-- local function GetAmmoGenericPistol(data)
--     DoEntFire(thisEntity:GetName().."_get_ammo", "FireUser4", tostring(Player.Items.ammo.generic_pistol), 0, data.activator, thisEntity)
-- end

-- ---Gets the number of frag grenades stored in the wrist pockets.
-- ---@param data TypeIOInvoke
-- local function GetItemGrenadeFrag(data)
--     DoEntFire(thisEntity:GetName().."_get_items", "FireUser1", tostring(Player.Items.grenades.frag), 0, data.activator, thisEntity)
-- end
-- ---Gets the number of xen grenades stored in the wrist pockets.
-- ---@param data TypeIOInvoke
-- local function GetItemGrenadeXen(data)
--     DoEntFire(thisEntity:GetName().."_get_items", "FireUser2", tostring(Player.Items.grenades.xen), 0, data.activator, data.caller)
-- end
-- ---Gets the number of healthpen syringes stored in the wrist pockets.
-- ---@param data TypeIOInvoke
-- local function GetItemHealthpen(data)
--     DoEntFire(thisEntity:GetName().."_get_items", "FireUser3", tostring(Player.Items.healthpen), 0, data.activator, data.caller)
-- end

---Gets the number of healthpen syringes stored in the wrist pockets.
---@param data TypeIOInvoke
local function GetMoveType(data)
    DoEntFire(thisEntity:GetName().."_get_move_type", "InValue", tostring(Player:GetMoveType()), 0, data.activator, data.caller)
end

---Gets the entity the player is looking at, otherwise activator isn't changed.
---@param data TypeIOInvoke
local function GetLookingAt(data)
    local ent = Player:GetLookingAt()
    DoEntFire(thisEntity:GetName().."_get_looking_at", "Trigger", "", 0, ent or data.activator, data.caller)
end

-- Add local functions to private script scope to avoid environment pollution.
local _a,_b=1,thisEntity:GetPrivateScriptScope()while true do local _c,_d=debug.getlocal(1,_a)if _c==nil then break end;if type(_d)=='function'then _b[_c]=_d end;_a=1+_a end
