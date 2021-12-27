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

---**The entity handle of the item held by this hand.**
---@type EntityHandle
CPropVRHand.ItemHeld = nil


-------------------------------
-- Class extension functions --
-------------------------------

---Forces the player to drop an entity if held.
---@param handle CBaseEntity # Handle of the entity to drop
function CBasePlayer:DropByHandle(handle)
    if IsValidEntity(handle) then
        local dmg = CreateDamageInfo(handle, handle, Vector(), Vector(), 0, 2)
        handle:TakeDamage(dmg)
        DestroyDamageInfo(dmg)
    end
end

---Forces the player to drop any item held in their left hand.
function CBasePlayer:DropLeftHand()
    self:DropByHandle(self.LeftHand)
end

---Forces the player to drop any item held in their right hand.
function CBasePlayer:DropRightHand()
    self:DropByHandle(self.RightHand)
end

---Forces the player to drop any item held in their primary hand.
function CBasePlayer:DropPrimaryHand()
    self:DropByHandle(self.PrimaryHand)
end

---Forces the player to drop any item held in their secondary/off hand.
function CBasePlayer:DropSecondaryHand()
    self:DropByHandle(self.SecondaryHand)
end

---Forces the player to drop this entity if held.
---@param self CBaseEntity
function CBaseEntity.Drop(self)
    Player:DropByHandle(self)
end
CBaseEntity.drop = CBaseEntity.Drop


-----------------------------------------------------
-- Global proxy functions for easy Hammer invoking --
-----------------------------------------------------

---Forces the player to drop any item held in their left hand.
function PlayerDropLeftHand()
    Player:DropLeftHand()
end

---Forces the player to drop any item held in their right hand.
function PlayerDropRightHand()
    Player:DropRightHand()
end

---Forces the player to drop any item held in their primary hand.
function PlayerDropPrimaryHand()
    Player:DropPrimaryHand()
end

---Forces the player to drop any item held in their secondary/off hand.
function PlayerDropSecondaryHand()
    Player:DropSecondaryHand()
end

---Forces the player to drop the caller entity if held.
---@param data TypeIOInvoke
function PlayerDropCaller(data)
    Player:DropByHandle(data.caller)
end

---Forces the player to drop the activator entity if held.
---@param data TypeIOInvoke
function PlayerDropActivator(data)
    Player:DropByHandle(data.activator)
end


-----------------
-- Local logic --
-----------------

-- Setting up player values.
local listenEventPlayerActivateID
local function listenEventPlayerActivate(_, data)
    Player = GetListenServerHost()
    Player:SetContextThink("global_player_setup_delay", function()
        Player.HMDAvatar = Player:GetHMDAvatar()
        if Player.HMDAvatar then
            Player.Hand[1] = Player.HMDAvatar:GetVRHand(0)
            Player.Hand[2] = Player.HMDAvatar:GetVRHand(1)
            Player.LeftHand = Player.Hand[1]
            Player.RightHand = Player.Hand[2]
            if Convars:GetBool("hlvr_left_hand_primary") then
                print("left handed")
                Player.PrimaryHand = Player.LeftHand
                Player.SecondaryHand = Player.RightHand
            else
                print("right handed")
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
    if data.vr_tip_attachment == nil then return end
    -- 1=primary,2=secondary converted to 0=left,1=right
    local handId = util.GetHandIdFromTip(data.vr_tip_attachment)
    local hand = Player.Hand[handId + 1]
    local hand_opposite = Player.Hand[(1 - handId) + 1]
    local ent_held = util.EstimateNearestEntity(data.item_name, data.item, hand:GetOrigin())

    hand.ItemHeld = ent_held
    -- If the item being dropped was in the opposite hand we can assume it isn't anymore.
    -- This might not be needed because item_released is fired when taken by other hand.
    if hand_opposite.ItemHeld == hand.ItemHeld then
        hand_opposite.ItemHeld = nil
    end
    print("Now in hand", hand.ItemHeld, hand.ItemHeld:GetName(), hand.ItemHeld:GetClassname())
end
ListenToGameEvent("item_pickup", listenEventItemPickup, _G)

local function listenEventItemReleased(_, data)
    if data.vr_tip_attachment == nil then return end
    print("ITEM WAS RELEASED", data.item_name)
    -- 1=primary,2=secondary converted to 0=left,1=right
    local handId = util.GetHandIdFromTip(data.vr_tip_attachment)
    local hand = Player.Hand[handId + 1]
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


