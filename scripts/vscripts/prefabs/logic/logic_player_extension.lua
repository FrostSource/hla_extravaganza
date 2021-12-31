--[[
    v1.0.0
    Prefab specific functions for prefabs/logic/player_extension/logic_player_extension.vmap
]]
require "util.player"

local items

-----------------------------
-- Getting Held Items
-----------------------------

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

-----------------------------
-- Getting Items Stored
-----------------------------

---Gets the number of energygun magazines stored in the backpack.
---@param data TypeIOInvoke
local function GetAmmoEnergygun(data)
    items:FireOutput("OnCase01", data.activator, thisEntity, tostring(Player.Items.ammo.energygun), 0)
end
---Gets the number of shotgun magazines stored in the backpack.
---@param data TypeIOInvoke
local function GetAmmoShotgun(data)
    items:FireOutput("OnCase02", data.activator, thisEntity, tostring(Player.Items.ammo.shotgun), 0)
end
---Gets the number of rapidfire magazines stored in the backpack.
---@param data TypeIOInvoke
local function GetAmmoRapidfire(data)
    items:FireOutput("OnCase03", data.activator, thisEntity, tostring(Player.Items.ammo.rapidfire), 0)
end
---Gets the number of energygun magazines stored in the backpack.
---@param data TypeIOInvoke
local function GetAmmoGenericPistol(data)
    items:FireOutput("OnCase04", data.activator, thisEntity, tostring(Player.Items.ammo.generic_pistol), 0)
end

---Gets the number of frag grenades stored in the wrist pockets.
---@param data TypeIOInvoke
local function GetItemGrenadeFrag(data)
    items:FireOutput("OnCase05", data.activator, thisEntity, tostring(Player.Items.grenades.frag), 0)
end
---Gets the number of xen grenades stored in the wrist pockets.
---@param data TypeIOInvoke
local function GetItemGrenadeXen(data)
    items:FireOutput("OnCase06", data.activator, thisEntity, tostring(Player.Items.grenades.xen), 0)
end
---Gets the number of healthpen syringes stored in the wrist pockets.
---@param data TypeIOInvoke
local function GetItemHealthpen(data)
    items:FireOutput("OnCase07", data.activator, thisEntity, tostring(Player.Items.healthpen), 0)
end


-----------------------------
-- Miscellaneous Functions
-----------------------------

---Gets the number of healthpen syringes stored in the wrist pockets.
---@param data TypeIOInvoke
local function GetMoveType(data)
    -- DoEntFire(thisEntity:GetName().."_get_move_type", "InValue", tostring(Player:GetMoveType()), 0, data.activator, data.caller)
    DoEntFire(thisEntity:GetName().."_get_move_type", "FireUser"..tostring(Player:GetMoveType()+1), "", 0, data.activator, thisEntity)
end

---Gets the entity the player is looking at, otherwise activator isn't changed.
---@param data TypeIOInvoke
local function GetLookingAt(data)
    local ent = Player:GetLookingAt()
    DoEntFire(thisEntity:GetName().."_get_looking_at", "Trigger", "", 0, ent or data.activator, data.caller)
end

---Forces the player to drop the caller entity if held.
---@param data TypeIOInvoke
local function DropCaller(data)
    Player:DropByHandle(data.caller)
end

---Forces the player to drop the activator entity if held.
---@param data TypeIOInvoke
local function DropActivator(data)
    Player:DropByHandle(data.activator)
end




-----------------------------
-- Game Restore Fix
-----------------------------

local function ready(saveLoaded)
    items = Entities:FindByName(nil, thisEntity:GetName().."_get_items")
end

-- Fix for script executing twice on restore.
-- This binds to the new local ready function on second execution.
---@diagnostic disable-next-line: undefined-field
if thisEntity:GetPrivateScriptScope().savewasloaded then
    thisEntity:SetContextThink("init", function() ready(true) end, 0)
end

---@param activateType "0"|"1"|"2"
function Activate(activateType)
    -- If game is being restored then set the script scope ready for next execution.
    if activateType == 2 then
        thisEntity:GetPrivateScriptScope().savewasloaded = true
        return
    end
    -- Otherwise just run the ready function after "instant" delay (player will be ready).
    thisEntity:SetContextThink("init", function() ready(false) end, 0)
end

-- Add local functions to private script scope to avoid environment pollution.
local _a,_b=1,thisEntity:GetPrivateScriptScope()while true do local _c,_d=debug.getlocal(1,_a)if _c==nil then break end;if type(_d)=='function'then _b[_c]=_d end;_a=1+_a end
