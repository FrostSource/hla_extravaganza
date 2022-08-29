--[[
    v1.0.0


]]

Input = {}

---Number of seconds after a press in which it can still be
---detected as a single press.
---Set this to 0 if your think functions use a 0 return.
---@type number
Input.PressedTolerance = 0.5

---Number of seconds after a released in which it can still be
---detected as a single release.
---Set this to 0 if your think functions use a 0 return.
---@type number
Input.ReleasedTolerance = 0.5

---Number of seconds after a press in which another press
---can be considered a double/triple (etc) press.
---@type number
Input.MultiplePressInterval = 0.15

---Example:
---{
---    -- Button literal
---    3 =
---    {
---        -- Hand ID
---        0 =
---        {
---            -- if the button is held
---            is_held = false,
---            -- Time() when the button was pressed
---            press_time = 0,
---            -- Time() when the button was released
---            release_time = 0,
---
---            press_callbacks = {}
---            release_callbacks = {}
---        }
---    }
---    
---}
---@type table<integer, table>
local tracked_buttons = {}

local function createButtonTable()
    return {
        is_held = false,
        press_time = -1,
        release_time = -1,
        press_locked = false,
        release_locked = false,
        press_callbacks = {},
        release_callbacks = {},
        multiple_press_count = 0,
    }
end

---Set a button to be tracked.
---@param button ENUM_DIGITAL_INPUT_ACTIONS
function Input:TrackButton(button)
    tracked_buttons[button] = {
        [0] = createButtonTable(),
        [1] = createButtonTable(),
    }
end

---Set an array of buttons to be tracked.
---@param buttons ENUM_DIGITAL_INPUT_ACTIONS[]
function Input:TrackButtons(buttons)
    for _, button in ipairs(buttons) do
        Input:TrackButton(button)
    end
end

---Stop all buttons from being tracked.
function Input:StopTrackingAllButtons()
    tracked_buttons = {}
end

---Set all buttons to be tracked.
function Input:TrackAllButtons()
    self:TrackButtons({
        0,1,2,3,4,5,6,7,8,9,10,
        11,12,13,14,15,16,17,18,19,
        20,21,22,23,24,25,26,27
    })
end

---Stop tracking a button.
---@param button ENUM_DIGITAL_INPUT_ACTIONS
function Input:StopTrackingButton(button)
    tracked_buttons[button] = nil
end


---Get if a button has just been pressed for a given hand.
---Optionally lock the button press so it can't be detected by other scripts until it is released.
---@param hand 0|1
---@param button ENUM_DIGITAL_INPUT_ACTIONS
---@param lock boolean?
---@return boolean
function Input:Pressed(hand, button, lock)
    local b = tracked_buttons[button]
    local h = b[hand]
    if h and not h.press_locked and h.is_held and (Time() - h.press_time) <= self.PressedTolerance then
        if lock then h.press_locked = true end
        return true
    end
    return false
end

---Get if a button has just been released for a given hand.
---Optionally lock the button release so it can't be detected by other scripts until it is pressed.
---@param hand 0|1
---@param button ENUM_DIGITAL_INPUT_ACTIONS
---@param lock boolean?
---@return boolean
function Input:Released(hand, button, lock)
    local b = tracked_buttons[button]
    local h = b[hand]
    if h and not h.release_locked and not h.is_held and (Time() - h.release_time) <= self.ReleasedTolerance then
        if lock then h.release_locked = true end
        return true
    end
    return false
end

---Get if a button is currently being held down for a given hand.
---@param hand 0|1
---@param button ENUM_DIGITAL_INPUT_ACTIONS
---@return boolean
function Input:Button(hand, button)
    local b = tracked_buttons[button]
    local h = b[hand]
    if h and h.is_held then
        return true
    end
    return false
end

---Get the amount of seconds a button has been held for a given hand.
---@param hand 0|1
---@param button ENUM_DIGITAL_INPUT_ACTIONS
---@return number
function Input:ButtonTime(hand, button)
    local b = tracked_buttons[button]
    local h = b[hand]
    if h and h.is_held then
        return Time() - h.press_time
    end
    return 0
end

local DESCS =
{
    [0] = "Menu > Toggle Menu",
    [1] = "Menu > Menu Interact",
    [2] = "Menu > Menu Dismiss",
    [3] = "Interact > Use",
    [4] = "Interact > Use Grip",
    [5] = "Weapon > Show inventory",
    [6] = "Interact > Grav Glove Lock",
    [7] = "Weapon > Fire",
    [8] = "Weapon > Alt Fire",
    [9] = "Weapon > Reload",
    [10] = "Weapon > Eject Magazine",
    [11] = "Weapon > Slide Release",
    [12] = "Weapon > Open Chamber",
    [13] = "Weapon > Toggle Laser Sight",
    [14] = "Weapon > Toggle Burst Fire",
    [15] = "Interact > Toggle Health Pen",
    [16] = "Interact > Arm Grenade",
    [17] = "Interact > Arm Xen Grenade",
    [18] = "Move > Teleport",
    [19] = "Move > Turn Left",
    [20] = "Move > Turn Right",
    [21] = "Move > Move Back",
    [22] = "Move > Walk",
    [23] = "Move > Jump",
    [24] = "Move > Mantle",
    [25] = "Move > Crouch Toggle",
    [26] = "Move > Stand toggle",
    [27] = "Move > Adjust Height",
}

---Get the description of a given button.
---Useful for debugging or hint display.
---@param button ENUM_DIGITAL_INPUT_ACTIONS
---@return string
function Input:GetButtonDescription(button)
    return DESCS[button]
end

---Register a callback for a specific button press/release.
---@param kind "press"|"release" # If the callback is registered for press or release.
---@param hand 0|1 # The ID of the hand to register on.
---@param button ENUM_DIGITAL_INPUT_ACTIONS # The button to check.
---@param presses integer|nil # Number of time the button must be pressed in quick succession. E.g. 2 for double click.
---@param callback function # The function that will be called on a successfull button press.
function Input:RegisterCallback(kind, hand, button, presses, callback)
    local b = tracked_buttons[button]
    local h = b[hand]
    if h then
        local t = h.press_callbacks
        if kind == "release" then t = h.release_callbacks end
        -- print('registering input callback', callback, 'in', t)
        t[callback] = presses or 1
    end
end

---Unregisters a specific callback from all buttons and hands.
---@param callback function
function Input:UnregisterCallback(callback)
    for button, hands in pairs(tracked_buttons) do
        for handid, data in pairs(hands) do
            for clbck, _ in pairs(data.press_callbacks) do
                if clbck == callback then
                    data.press_callbacks[clbck] = nil
                end
            end
            for clbck, _ in pairs(data.release_callbacks) do
                if clbck == callback then
                    data.release_callbacks[clbck] = nil
                end
            end
        end
    end
end


---Get if a button has just been pressed for this hand.
---Optionally lock the button press so it can't be detected by other scripts until it is released.
---@param button ENUM_DIGITAL_INPUT_ACTIONS
---@param lock boolean?
---@return boolean
function CPropVRHand:Pressed(button, lock)
    return Input:Pressed(self:GetHandID(), button, lock)
end

---Get if a button has just been released for this hand.
---Optionally lock the button release so it can't be detected by other scripts until it is pressed.
---@param button ENUM_DIGITAL_INPUT_ACTIONS
---@param lock boolean?
---@return boolean
function CPropVRHand:Released(button, lock)
    return Input:Released(self:GetHandID(), button, lock)
end

---Get if a button is currently being held down for a this hand.
---@param button ENUM_DIGITAL_INPUT_ACTIONS
---@return boolean
function CPropVRHand:Button(button)
    return Input:Button(self:GetHandID(), button)
end

---Get the amount of seconds a button has been held for this hand.
---@param button ENUM_DIGITAL_INPUT_ACTIONS
---@return number
function CPropVRHand:ButtonTime(button)
    return Input:ButtonTime(self:GetHandID(), button)
end


---@class INPUT_PRESS_CALLBACK
---@field kind "press"
---@field press_time number
---@field hand CPropVRHand
---@field button ENUM_DIGITAL_INPUT_ACTIONS

---@class INPUT_RELEASE_CALLBACK
---@field kind "release"
---@field release_time number
---@field hand CPropVRHand
---@field button ENUM_DIGITAL_INPUT_ACTIONS

---@alias INPUT_CALLBACK INPUT_RELEASE_CALLBACK|INPUT_PRESS_CALLBACK

local function InputThink()
    local player = Entities:GetLocalPlayer()
    local hmd = player:GetHMDAvatar()
    if not hmd then
        Warning("Input could not find HMD, make sure VR mode is enabled. Disabling...")
        return nil
    end

    for button, hands in pairs(tracked_buttons) do
        for handid, data in pairs(hands) do
            local hand = hmd:GetVRHand(handid)
            if player:IsDigitalActionOnForHand(hand:GetLiteralHandType(), button) then
                -- print("Held time", Input:ButtonTime(handid, button), Time(), data.press_time)
                if data.press_time == -1 then
                    data.is_held = true
                    data.release_locked = false
                    if Time() - data.press_time <= Input.MultiplePressInterval then
                        data.multiple_press_count = data.multiple_press_count + 1
                    else
                        data.multiple_press_count = 0
                    end
                    data.press_time = Time()
                    data.release_time = -1
                    -- print(Input:GetButtonDescription(button).."pressed", "multiple_press: "..data.multiple_press_count)
                    local send = {
                        kind = "press",
                        press_time = data.press_time,
                        hand = hand,
                        button = button,
                    }
                    -- print('doing press callbacks', data.press_callbacks, 'for hand', handid)
                    for callback, _ in pairs(data.press_callbacks) do
                        -- print('', callback)
                        callback(send)
                    end
                end
            elseif data.release_time == -1 then
                data.is_held = false
                data.press_locked = false
                data.release_time = Time()
                data.press_time = -1
                -- print(Input:GetButtonDescription(button), "released")
                local send = {
                    kind = "release",
                    release_time = data.release_time,
                    hand = hand,
                    button = button,
                }
                for callback, _ in pairs(data.release_callbacks) do
                    callback(send)
                end
            end
        end
    end

    return 0
end

function Input:StartTrackingOn(ent)
    ent:SetContextThink("InputThink", InputThink, 0)
end

-- ListenToGameEvent("player_activate", function()
--     print("Initiating input think...")
--     Entities:GetLocalPlayer():SetContextThink("InputThink", InputThink, 0)
-- end, nil)


