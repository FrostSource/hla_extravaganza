--[[
    v1.0.0

    Player script allows for more advanced player manipulation and easier
    entity access for player related entities by extending the player class.

    Include this script into the global scope using the following line:

        require "util.player"

    -

    Useful Player methods are replicated as global functions so they
    can easily be invoked in Hammer using 'CallGlobalScriptFunction'.

    -

    Common method for referencing the player and related entities is:

    local player = Entities:GetLocalPlayer()
    local hmd_avatar = player:GetHMDAvatar()
    local left_hand = hmd_avatar:GetVRHand(0)
    local right_hand = hmd_avatar:GetVRHand(1)

    This script simplifies the above code significantly by automatically
    caching player entity handles when the player spawns and introducing
    the global variable 'Player' which references the base player entity:

    local player = Player
    local hmd_avatar = Player.HMDAvatar
    local left_hand = Player.LeftHand
    local right_hand = Player.RightHand

    Since this script extends the player entity class directly you can
    mix and match your scripting style without worrying that you're
    referencing the wrong player table.

    -

    The script attempts to track which item is currently being held in each hand
    which can be accessed using the extended CPropVRHand member 'ItemHeld':

    local primary_held_name = Player.PrimaryHand.ItemHeld:GetName()

]]
require "util.util"
require "util.storage"

-----------------------------
-- Class extension members --
-----------------------------

---**The base player entity.**
---@type CBasePlayer
Player = nil
---**The entity handle of the VR headset (if in VR mode).**
---@type CPropHMDAvatar
CBasePlayer.HMDAvatar = nil
---**The entity handle of the VR anchor (if in VR mode).**
---@type CEntityInstance
CBasePlayer.HMDAnchor = nil
---**1 = Left hand, 2 = Right hand.**
---@type CPropVRHand[]
CBasePlayer.Hand = {}
---**Player's left hand.**
---@type CPropVRHand
CBasePlayer.LeftHand = nil
---**Player's right hand.**
---@type CPropVRHand
CBasePlayer.RightHand = nil
---**Player's primary hand.**
---@type CPropVRHand
CBasePlayer.PrimaryHand = nil
---**Player's secondary hand.**
---@type CPropVRHand
CBasePlayer.SecondaryHand = nil
---**If the player is left handed.**
---@type boolean
CBasePlayer.IsLeftHanded = false
---**The last entity that was dropped by the player.**
---@type EntityHandle
CBasePlayer.LastItemDropped = nil
---**The classname of the last entity dropped by the player. In case the entity no longer exists.**
---@type string
CBasePlayer.LastClassDropped = ""
---**The last entity that was grabbed by the player.**
---@type EntityHandle
CBasePlayer.LastItemGrabbed = nil
---**The classname of the last entity grabbed by the player. In case the entity no longer exists.**
---@type string
CBasePlayer.LastClassGrabbed = ""

PLAYER_WEAPON_HAND           = "hand_use_controller"
PLAYER_WEAPON_ENERGYGUN      = "hlvr_weapon_energygun"
PLAYER_WEAPON_RAPIDFIRE      = "hlvr_weapon_rapidfire"
PLAYER_WEAPON_SHOTGUN        = "hlvr_weapon_shotgun"
PLAYER_WEAPON_MULTITOOL      = "hlvr_multitool"
PLAYER_WEAPON_GENERIC_PISTOL = "hlvr_weapon_generic_pistol"

---**The classname of the weapon/item attached to hand.
---@type string|"PLAYER_WEAPON_HAND"|"PLAYER_WEAPON_ENERGYGUN"|"PLAYER_WEAPON_RAPIDFIRE"|"PLAYER_WEAPON_SHOTGUN"|"PLAYER_WEAPON_MULTITOOL"|"PLAYER_WEAPON_GENERIC_PISTOL"
CBasePlayer.CurrentWeapon = PLAYER_WEAPON_HAND

---**Table of items player currently has possession of.**
CBasePlayer.Items = {
    grenades = {
        ---Frag grenades.
        frag = 0,
        ---Xen grenades.
        xen = 0,
    },
    ---Healthpen syringes.
    healthpen = 0,
    ammo = {
        ---Ammo for the main pistol. This is number of magazines, not bullets. Multiply by 10 to get bullets.
        energygun = 0,
        ---Ammo for the rapidfire pistol. This is number of magazines, not bullets. Multiply by 30 to get bullets.
        rapidfire = 0,
        ---Ammo for the shotgun. This is number of shells.
        shotgun = 0,
        ---Ammo for the generic pistol. This is number of magazines, not bullets.
        generic_pistol = 0,
    }
}

---**The entity handle of the item held by this hand.**
---@type EntityHandle
CPropVRHand.ItemHeld = nil
---**The last entity that was dropped by this hand.**
---@type EntityHandle
CPropVRHand.LastItemDropped = nil
---**The classname of the last entity dropped by this hand. In case the entity no longer exists.**
---@type string
CPropVRHand.LastClassDropped = ""
---**The last entity that was grabbed by this hand.**
---@type EntityHandle
CPropVRHand.LastItemGrabbed = nil
---**The classname of the last entity grabbed by this hand. In case the entity no longer exists.**
---@type string
CPropVRHand.LastClassGrabbed = ""


-------------------------------
-- Class extension functions --
-------------------------------

---Force the player to drop an entity if held.
---@param handle CBaseEntity # Handle of the entity to drop
function CBasePlayer:DropByHandle(handle)
    if IsValidEntity(handle) then
        local dmg = CreateDamageInfo(handle, handle, Vector(), Vector(), 0, 2)
        handle:TakeDamage(dmg)
        DestroyDamageInfo(dmg)
    end
end

---Force the player to drop any item held in their left hand.
function CBasePlayer:DropLeftHand()
    self:DropByHandle(self.LeftHand)
end
util.SanitizeFunctionForHammer(CBasePlayer.DropLeftHand, "DropLeftHand", CBasePlayer)

---Force the player to drop any item held in their right hand.
function CBasePlayer:DropRightHand()
    self:DropByHandle(self.RightHand)
end
util.SanitizeFunctionForHammer(CBasePlayer.DropRightHand, "DropRightHand", CBasePlayer)

---Force the player to drop any item held in their primary hand.
function CBasePlayer:DropPrimaryHand()
    self:DropByHandle(self.PrimaryHand)
end
util.SanitizeFunctionForHammer(CBasePlayer.DropPrimaryHand, "DropPrimaryHand", CBasePlayer)

---Force the player to drop any item held in their secondary/off hand.
function CBasePlayer:DropSecondaryHand()
    self:DropByHandle(self.SecondaryHand)
end
util.SanitizeFunctionForHammer(CBasePlayer.DropSecondaryHand, "DropSecondaryHand", CBasePlayer)

---Force the player to drop the caller entity if held.
---@param data TypeIOInvoke
function CBasePlayer:DropCaller(data)
    self:DropByHandle(data.caller)
end
util.SanitizeFunctionForHammer(CBasePlayer.DropCaller, "DropCaller", CBasePlayer)

---Force the player to drop the activator entity if held.
---@param data TypeIOInvoke
function CBasePlayer:DropActivator(data)
    self:DropByHandle(data.activator)
end
util.SanitizeFunctionForHammer(CBasePlayer.DropActivator, "DropActivator", CBasePlayer)

PLAYER_MOVETYPE_TELEPORT_BLINK  = 0
PLAYER_MOVETYPE_TELEPORT_SHIFT  = 1
PLAYER_MOVETYPE_CONTINUOUS_HEAD = 2
PLAYER_MOVETYPE_CONTINUOUS_HAND = 3

---Get VR movement type.
---@return "PLAYER_MOVETYPE_TELEPORT_BLINK"|"PLAYER_MOVETYPE_TELEPORT_SHIFT"|"PLAYER_MOVETYPE_CONTINUOUS_HEAD"|"PLAYER_MOVETYPE_CONTINUOUS_HAND"
function CBasePlayer:GetMoveType()
    local movetype = Convars:GetInt('hlvr_movetype_default')
    return movetype
end

---Returns the entity the player is looking at directly.
---@param maxDistance? number # Max distance the trace can search.
---@return EntityHandle
function CBasePlayer:GetLookingAt(maxDistance)
    maxDistance = maxDistance or 2048
    ---@type TypeTraceTableLine
    local traceTable = {
        startpos = self:EyePosition(),
        endpos = self:EyePosition() + AnglesToVector(self:EyeAngles()) * maxDistance,
        ignore = self,
    }
    if TraceLine(traceTable) then
        return traceTable.enthit
    end
    return nil
end

---Disables fall damage for the player.
function CBasePlayer:DisableFallDamage()
    local name = Storage.LoadString(self, "FallDamageFilterName", DoUniqueString("__player_fall_damage_filter"))
    Storage.SaveString(self, "FallDamageFilterName", name)
    local filter = Entities:FindByName(nil, name) or SpawnEntityFromTableSynchronous("filter_damage_type",{
        targetname = name,
        damagetype = "32"
    })
    DoEntFireByInstanceHandle(self, "SetDamageFilter", name, 0, self, self)
end
util.SanitizeFunctionForHammer(CBasePlayer.DisableFallDamage, "DisableFallDamage", CBasePlayer)

---Enables fall damage for the player.
function CBasePlayer:EnableFallDamage()
    --Killing the filter is not necessary but may be helpful.
    local name = Storage.LoadString(self, "FallDamageFilterName", "")
    if name ~= "" then
        local filter = Entities:FindByName(nil, name)
        if filter then filter:Kill() end
    end
    DoEntFireByInstanceHandle(self, "SetDamageFilter", "", 0, self, self)
end
util.SanitizeFunctionForHammer(CBasePlayer.EnableFallDamage, "EnableFallDamage", CBasePlayer)

---Adds resources to the player.
---@param pistol_ammo? number
---@param rapidfire_ammo? number
---@param shotgun_ammo? number
---@param resin? number
function CBasePlayer:AddResources(pistol_ammo, rapidfire_ammo, shotgun_ammo, resin)
    SendToServerConsole("hlvr_addresources "..(pistol_ammo or 0).." "..(rapidfire_ammo or 0).." "..(shotgun_ammo or 0).." "..(resin or 0))

    -- For setting resources if ever find a way to track resin
    -- SendToServerConsole("hlvr_setresources "..
    --     (pistol_ammo or self.Items.ammo.energygun*10).." "..
    --     (rapidfire_ammo or self.Items.ammo.rapidfire*30).." "..
    --     (shotgun_ammo or self.Items.ammo.shotgun).." "..
    --     (resin or self.Items.resin)
    -- )
end

---Add pistol ammo to the player.
---@param amount number
function CBasePlayer:AddPistolAmmo(amount)
    self:AddResources(amount, nil, nil, nil)
end
---Add shotgun ammo to the player.
---@param amount number
function CBasePlayer:AddShotgunAmmo(amount)
    self:AddResources(nil, nil, amount, nil)
end
---Add rapidfire ammo to the player.
---@param amount number
function CBasePlayer:AddRapidfireAmmo(amount)
    self:AddResources(nil, amount, nil, nil)
end
---Add resin to the player.
---@param amount number
function CBasePlayer:AddResin(amount)
    self:AddResources(nil, nil, nil, amount)
end

---Forces the player to drop this entity if held.
---@param self CBaseEntity
function CBaseEntity:Drop()
    Player:DropByHandle(self)
end
-- CBaseEntity.drop = CBaseEntity.Drop
print(CBaseEntity)
print(_G)
util.SanitizeFunctionForHammer(CBaseEntity.Drop, "Drop", CBaseEntity)


-----------------
-- Local logic --
-----------------

local shellgroup_cache = 0

local function savePlayerData()
    Storage.SaveTable(Player, "PlayerItems", Player.Items)
end

local function loadPlayerData()
    Storage.LoadTable(Player, "PlayerItems", Player.Items)
end

-- Setting up player values.
local listenEventPlayerActivateID
local function listenEventPlayerActivate(_, data)
    Player = GetListenServerHost()
    loadPlayerData()
    Player:SetContextThink("global_player_setup_delay", function()
        Player.HMDAvatar = Player:GetHMDAvatar()
        if Player.HMDAvatar then
            Player.Hand[1] = Player.HMDAvatar:GetVRHand(0)
            Player.Hand[2] = Player.HMDAvatar:GetVRHand(1)
            Player.LeftHand = Player.Hand[1]
            Player.RightHand = Player.Hand[2]
            Player.IsLeftHanded = Convars:GetBool("hlvr_left_hand_primary")
            if Player.IsLeftHanded then
                Player.PrimaryHand = Player.LeftHand
                Player.SecondaryHand = Player.RightHand
            else
                Player.PrimaryHand = Player.RightHand
                Player.SecondaryHand = Player.LeftHand
            end
            Player.HMDAnchor = Player:GetHMDAnchor()
        end
    end, 0)
    StopListeningToGameEvent(listenEventPlayerActivateID)
end
listenEventPlayerActivateID = ListenToGameEvent("player_activate", listenEventPlayerActivate, _G)

-- Tracking player held items.
local function listenEventItemPickup(_, data)
    -- print("\nITEM PICKUP:")
    -- util.PrintTable(data)
    -- print("\n")
    if data.vr_tip_attachment == nil then return end
    -- 1=primary,2=secondary converted to 0=left,1=right
    local handId = util.GetHandIdFromTip(data.vr_tip_attachment)
    local hand = Player.Hand[handId + 1]
    local hand_opposite = Player.Hand[(1 - handId) + 1]
    local ent_held = util.EstimateNearestEntity(data.item_name, data.item, hand:GetOrigin())

    hand.ItemHeld = ent_held
    hand.LastItemGrabbed = ent_held
    hand.LastClassGrabbed = data.item
    Player.LastItemGrabbed = ent_held
    Player.LastClassGrabbed = data.item

    -- If the item being dropped was in the opposite hand we can assume it isn't anymore.
    -- This might not be needed because item_released is fired when taken by other hand.
    if hand_opposite.ItemHeld == hand.ItemHeld then
        hand_opposite.ItemHeld = nil
    end
end
ListenToGameEvent("item_pickup", listenEventItemPickup, _G)

local function listenEventItemReleased(_, data)
    -- print("\nITEM RELEASED:")
    -- util.PrintTable(data)
    -- print("\n")
    if data.vr_tip_attachment == nil then return end
    -- 1=primary,2=secondary converted to 0=left,1=right
    local handId = util.GetHandIdFromTip(data.vr_tip_attachment)
    local hand = Player.Hand[handId + 1]
    -- Hack to get the number of shells dropped
    if data.item == "item_hlvr_clip_shotgun_shellgroup" then
        shellgroup_cache = #hand.ItemHeld:GetChildren()
    end
    Player.LastItemDropped = hand.ItemHeld
    Player.LastClassDropped = data.item
    hand.LastItemDropped = hand.ItemHeld
    hand.LastClassDropped = data.item
    hand.ItemHeld = nil
end
ListenToGameEvent("item_released", listenEventItemReleased, _G)

-- Tracking handedness.
local function listenEventPrimaryHandChanged(_, data)
    if data.is_primary_left then
        Player.PrimaryHand = Player.LeftHand
        Player.SecondaryHand = Player.RightHand
    else
        Player.PrimaryHand = Player.RightHand
        Player.SecondaryHand = Player.LeftHand
    end
end
ListenToGameEvent("primary_hand_changed", listenEventPrimaryHandChanged, _G)

local function listenEventPlayerDropAmmoInBackpack(_, data)
    -- print("\nSTORE AMMO:")
    -- util.PrintTable(data)
    -- print("\n")

    --Pistol (energygun)
    --SMG1 (rapidfire)
    --Buckshot (shotgun)
    --AlyxGun (generic pistol)

    -- Sometimes for some reason the key is `ammoType` (capital T), seems to happen when shotgun shell is taken from backpack and put back.
    local ammotype = data.ammotype or data.ammoType
    -- Energygun
    if ammotype == "Pistol" then
        if Player.LastClassDropped == "item_hlvr_clip_energygun_multiple" then
            Player.Items.ammo.energygun = Player.Items.ammo.energygun + 4
            -- print("Player stored 4 energygun clips")
        else
            Player.Items.ammo.energygun = Player.Items.ammo.energygun + 1
            -- print("Player stored 1 energygun clip")
        end
    -- Rapidfire
    elseif ammotype == "SMG1" then
        Player.Items.ammo.rapidfire = Player.Items.ammo.rapidfire + 1
        -- print("Player stored 1 rapidfire clip")
    -- Shotgun (how to get shellgroup count?)
    elseif ammotype == "Buckshot" then
        if Player.LastClassDropped == "item_hlvr_clip_shotgun_multiple" then
            Player.Items.ammo.shotgun = Player.Items.ammo.shotgun + 4
            -- print("Player stored 4 shotgun shells")
        elseif Player.LastClassDropped == "item_hlvr_clip_shotgun_shellgroup" then
            -- this can be 2 or 3.. how to figure out??
            Player.Items.ammo.shotgun = Player.Items.ammo.shotgun + shellgroup_cache--2--3
            -- print("Player stored "..shellgroup_cache .." shotgun shells")
        else
            Player.Items.ammo.shotgun = Player.Items.ammo.shotgun + 1
            -- print("Player stored 1 shotgun shell")
        end
    -- Generic pistol
    elseif ammotype == "AlyxGun" then
        if Player.LastClassDropped == "item_hlvr_clip_generic_pistol_multiple" then
            Player.Items.ammo.generic_pistol = Player.Items.ammo.generic_pistol + 4
            -- print("Player stored 4 generic pistol clips")
        else
            Player.Items.ammo.generic_pistol = Player.Items.ammo.generic_pistol + 1
            -- print("Player stored 1 generic pistol clip")
        end
    else
        print("Couldn't figure out ammo for "..tostring(ammotype))
    end
    savePlayerData()
end
ListenToGameEvent("player_drop_ammo_in_backpack", listenEventPlayerDropAmmoInBackpack, _G)

local function listenEventPlayerRetrievedBackpackClip(_, data)
    -- print("\nRETRIEVE AMMO:")
    -- util.PrintTable(data)
    -- print("\n")

    if Player.CurrentWeapon == PLAYER_WEAPON_ENERGYGUN
    or Player.CurrentWeapon == PLAYER_WEAPON_HAND
    or Player.CurrentWeapon == PLAYER_WEAPON_MULTITOOL then
        Player.Items.ammo.energygun = Player.Items.ammo.energygun - 1
    elseif Player.CurrentWeapon == PLAYER_WEAPON_RAPIDFIRE then
        Player.Items.ammo.rapidfire = Player.Items.ammo.rapidfire - 1
    elseif Player.CurrentWeapon == PLAYER_WEAPON_SHOTGUN then
        -- Delayed think is used because item_pickup is fired after this event
        Player:SetContextThink("delay_shotgun_shellgroup", function()
            -- Player always retrieves a shellgroup even if no autoloader and single shell
            -- checking just in case
            if Player.LastClassGrabbed == "item_hlvr_clip_shotgun_shellgroup" then
                Player.Items.ammo.shotgun = Player.Items.ammo.shotgun - #Player.LastItemGrabbed:GetChildren()
            end
        end, 0)
    elseif Player.CurrentWeapon == PLAYER_WEAPON_GENERIC_PISTOL then
        Player.Items.ammo.generic_pistol = Player.Items.ammo.generic_pistol - 1
    end
    savePlayerData()
end
ListenToGameEvent("player_retrieved_backpack_clip", listenEventPlayerRetrievedBackpackClip, _G)

local function listenEventPlayerStoredItemInItemholder(_, data)
    -- print("\nSTORE WRIST:")
    -- util.PrintTable(data)
    -- print("\n")

    if data.item == "item_hlvr_grenade_frag" then
        Player.Items.grenades.frag = Player.Items.grenades.frag + 1
    elseif data.item == "item_hlvr_grenade_xen" then
        Player.Items.grenades.xen = Player.Items.grenades.xen + 1
    elseif data.item == "item_healthvial" then
        Player.Items.healthpen = Player.Items.healthpen + 1
    end
    savePlayerData()
end
ListenToGameEvent("player_stored_item_in_itemholder", listenEventPlayerStoredItemInItemholder, _G)

local function listenEventPlayerRemovedItemFromItemholder(_, data)
    -- print("\nREMOVE FROM WRIST:")
    -- util.PrintTable(data)
    -- print("\n")

    if data.item == "item_hlvr_grenade_frag" then
        Player.Items.grenades.frag = Player.Items.grenades.frag - 1
    elseif data.item == "item_hlvr_grenade_xen" then
        Player.Items.grenades.xen = Player.Items.grenades.xen - 1
    elseif data.item == "item_healthvial" then
        Player.Items.healthpen = Player.Items.healthpen - 1
    end
    savePlayerData()
end
ListenToGameEvent("player_removed_item_from_itemholder", listenEventPlayerRemovedItemFromItemholder, _G)

-- No known way to track resin being taken out reliably.
-- local function listenEventPlayerDropResinInBackpack(_, data)
--     -- print("\nSTORE RESIN:")
--     -- util.PrintTable(data)
--     -- print("\n")
-- end
-- ListenToGameEvent("player_drop_resin_in_backpack", listenEventPlayerDropResinInBackpack, _G)

local function listenEventWeaponSwitch(_, data)
    -- print("\nWEAPON SWITCH:")
    -- util.PrintTable(data)
    -- print("\n")

    Player.CurrentWeapon = data.item
end
ListenToGameEvent("weapon_switch", listenEventWeaponSwitch, _G)
