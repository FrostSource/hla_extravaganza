--[[
    v0.1.0
    https://github.com/FrostSource/hla_extravaganza

    Attaching this script to your trigger_look entity will augment it to allow
    testing the look from any given class or targetname.

    Attach to your entity in Misc > Entity Scripts = entity_mods/trigger_look_arbitrary

    Because there is no easy way to hijack the actual outputs this script instead
    fires the OnUser* outputs. This means it is important to remember
    to NOT use the OnStartLook, OnEndLook, or OnTrigger outputs,
    as these are still tied to the player eyes.
    However this also means you can test from the player eyes AND another entity at the same time.

    OnUser1 - Equivalent to OnStartLook, fired only once when the entity looks at the target.
    OnUser2 - Equivalent to OnEndLook, fired only once when the entity looks away from the target.
    OnUser3 - Equivalent to OnTrigger, fired every "Look Time" seconds while looking at the target.

    Every OnUser* output gets the target entity that was looked at passed into !activator
    This is generally only useful when you have multiple targets and are using CheckAllTargets.

    It is recommended that you untick the "Fire Once" spawnflag and disable the trigger
    through other means, for example OnUser1, as the player looking detection is still active.


    Several custom keys can be added to your trigger_look to set the behaviour.
    To add a key click the "+ Add Key" button at the top of the object properties.

    Name               Type       Description
    -----------------------------------------------------------------------------------
    LookFromClass      (string)   The classname of the entity to do the look test from.
                                  This may be omitted if you are using LookFromName.

    LookFromName       (string)   The targetname of the entity to do the look test from.
                                  This property takes precedence over LookFromClass.
                                  This may be omitted if you are using LookFromClass.

    LookFromAttachment (string)   The attachment name on the model to look from.
                                  This is both the origin and forward direction.
                                  This may be omitted if you are not using an attachment.

    CheckAllTargets    (integer)  Set to 1 to allow multiple targets with the same name
                                  to be checked at once. The first one to be looked at
                                  will be passed as the !activator when OnUser* is fired.
                                  This may be omitted if you don't want to use it.


    You can set the above properties in-game as well as in Hammer.
    Send an input of RunScriptCode to your trigger_look with a
    parameter override as one of the following:

    SetLookFromClass('class_name_here')
    SetLookFromName('target_name_here')
    SetLookFromAttachment('attach_name_here')
    SetCheckAllTargets(true or false)

    Examples:

    SetLookFromClass('hlvr_flashlight_attachment')
    SetLookFromName('flashlight')
    SetLookFromAttachment('light_attach')
    SetCheckAllTargets(true)

    For in-game debugging purposes you can toggle debug visuals for the current session
    by calling the function ToggleDebug on any trigger_look with the script attached.

    CallPrivateScriptFunction -> ToggleDebug

]]
require "util.util"
require "util.storage"

--- Properties relating directly to the Hammer entity.

local target_name = ""
local look_time = 0.5
local fov = 0.9
local use_2d = false
local test_occlusion = false
local look_from_class = ""
local look_from_name = ""
local look_from_attachment_name = ""
local check_all_targets = false

--- Internal variables.

---The target handle found from `target_name`.
---@type EntityHandle
local target = nil
---The look from handle found from `look_from_class`.
---@type EntityHandle
local look_from_handle = nil
---The real index found from `look_from_attachment_name`.
local look_from_attachment_index = 0
---Time when the entity first catches glimpse of `target`
---Used to track length of look time.
local start_look_time = -1
---Target is currently being looked at after `look_time`.
local looked_at_target = false
---OnStartTouchAll activator.
---@type EntityHandle
local current_activator = nil
---OnEndTouchAll activator.
---@type EntityHandle
local current_caller = nil
local debug_enabled = false

---Set the class to test looking from.
---e.g. SetLookFromClass('hlvr_flashlight_attachment')
---@param class string
local function SetLookFromClass(class)
    look_from_class = class or look_from_class
    thisEntity:SaveString("script.LookFromClass", look_from_class)
end

---Set the targetname to test looking from.
---This takes precedence over `look_from_class`.
---e.g. SetLookFromName('my_flashlight')
---@param targetname string
local function SetLookFromName(targetname)
    look_from_name = targetname or look_from_name
    thisEntity:SaveString("script.LookFromName", look_from_name)
end

---Set the attachment on the model to test looking from.
---Both origin and forward of the attachment are used.
---e.g. SetLookFromAttachment('light_attach')
---@param attachment_name string # Set blank to use model origin and forward.
local function SetLookFromAttachment(attachment_name)
    look_from_attachment_name = attachment_name or look_from_attachment_name
    thisEntity:SaveString("script.LookFromAttachment", look_from_attachment_name)
end

---Set if the script should check all named targets or only one.
---@param check_all boolean
local function SetCheckAllTargets(check_all)
    check_all_targets = check_all
    thisEntity:SaveBoolean("script.CheckAllTargets", check_all_targets)
end

---Toggles debug state. This is not saved between sessions.
local function ToggleDebug()
    debug_enabled = not debug_enabled
end


---Get if the look from entity can see a given `handle`.
---@param look_origin Vector
---@param look_forward Vector
---@param handle EntityHandle
---@return boolean
local function IsLookingAtHandle(look_origin, look_forward, handle)
    local pos = (handle:GetOrigin() - look_origin):Normalized()
    if use_2d then
        -- what is the best way to convert 3d forward to 2d?
        -- this gives rough matching output as trigger
        look_forward = look_forward * 100
        look_forward.z = 0
        look_forward = look_forward:Normalized()
        pos.z = 0
    end

    local can_see_target = false
    -- 2013 engine uses greater than, not greater or equal
    -- https://github.com/ValveSoftware/source-sdk-2013/blob/0d8dceea4310fde5706b3ce1c70609d72a38efdf/sp/src/game/server/triggers.cpp#L1149
    local dot = look_forward:Dot(pos)
    if dot > fov then
        can_see_target = true
        if test_occlusion then
            ---@type TraceTableLine
            local traceTable = {
                startpos = look_origin,
                endpos = handle:GetOrigin(),
                ignore = look_from_handle,
            }
            TraceLine(traceTable)
            if traceTable.hit and traceTable.enthit ~= handle then
                can_see_target = false
            end
        end
    end
    return can_see_target, dot
end

---Main think for trigger.
---@return number # Update interval
local function ThinkFlashlightAim()
    if not target or not IsValidEntity(target) then
        target = Entities:FindByName(nil, target_name)
        if not target then return nil end
    end

    local look_forward
    local look_origin
    if look_from_class == "player" then
        look_forward = AnglesToVector(look_from_handle:EyeAngles())
        look_origin = look_from_handle:EyePosition()
    else
        -- Only model entities have these methods
        if look_from_handle.GetAttachmentForward then
            look_forward = look_from_handle:GetAttachmentForward(look_from_attachment_index)
            look_origin = look_from_handle:GetAttachmentOrigin(look_from_attachment_index)
        else
            look_forward = look_from_handle:GetForwardVector()
            look_origin = look_from_handle:GetOrigin()
        end
    end

    local can_see_target = false
    local seen_target = target
    if check_all_targets then
        for _, targ in ipairs(Entities:FindAllByName(target_name)) do
            if IsLookingAtHandle(look_origin, look_forward, targ) then
                can_see_target = true
                seen_target = targ
                break
            end
        end
    else
        local can_see, dot = IsLookingAtHandle(look_origin, look_forward, target)
        if can_see then
            can_see_target = true
        end
        --Debug the look from vectors in-game, currently only for one target
        if debug_enabled then
            debugoverlay:Sphere(look_origin, 3, 255, 0, 0, 255, false, 0)
            debugoverlay:Sphere(target:GetOrigin(), 3, 0, 0, 255, 255, false, 0)
            debugoverlay:Line(look_origin, look_origin+look_forward*64, 255, 0, 0, 255, false, 0)
            debugoverlay:Line(look_origin, look_origin+(target:GetOrigin()-look_origin):Normalized()*64, 0, 0, 255, 255, false, 0)
            debugoverlay:Text(look_origin, 0, string.format("FOV: %.2f / %.2f", dot, fov), 64, 0, 0, 255, 255, 0)
        end
    end

    if can_see_target then
        if start_look_time == -1 then
            start_look_time = Time()
        end
        if Time() - start_look_time >= look_time then
            -- OnTrigger
            DoEntFireByInstanceHandle(thisEntity, "FireUser3", "", 0, seen_target, current_caller)
            start_look_time = -1
            if not looked_at_target then
                looked_at_target = true
                -- OnStartLook
                DoEntFireByInstanceHandle(thisEntity, "FireUser1", "", 0, seen_target, current_caller)
            end
        end
    else
        start_look_time = -1
        if looked_at_target then
            looked_at_target = false
            -- OnEndLook
            DoEntFireByInstanceHandle(thisEntity, "FireUser2", "", 0, seen_target, current_caller)
        end
    end

    return 0
end

---Output redirected here.
---@param input TypeIOInvoke
local function OnStartTouchAll(input)
    current_activator = input.activator
    current_caller = input.caller
    target = Entities:FindByName(nil, target_name)
    if look_from_name ~= "" then
        look_from_handle = Entities:FindByName(nil, look_from_name)
    else
        look_from_handle = Entities:FindByClassname(nil, look_from_class)
    end
    if target and look_from_handle then
        if look_from_handle.ScriptLookupAttachment then
            look_from_attachment_index = look_from_handle:ScriptLookupAttachment(look_from_attachment_name)
        end
        -- print("looking from", look_from_class, look_from_handle, look_from_attachment_name)
        thisEntity:SetThink(ThinkFlashlightAim, "ThinkFlashlightAim", 0)
    else
        if not target then Warning("trigger_look_arbitrary.lua Could not find target!\n") end
        if not look_from_handle then Warning("trigger_look_arbitrary.lua Could not find look from entity!\n") end
    end
end

---Output redirected here.
---@param input TypeIOInvoke
local function OnEndTouchAll(input)
    start_look_time = -1
    looked_at_target = false
    thisEntity:StopThink("ThinkFlashlightAim")
end

---@param spawnkeys CScriptKeyValues
function Spawn(spawnkeys)
    thisEntity:SaveString("script.target", spawnkeys:GetValue("target") or target_name)
    thisEntity:SaveNumber("script.LookTime", tonumber(spawnkeys:GetValue("LookTime")))
    thisEntity:SaveNumber("script.FieldOfView", tonumber(spawnkeys:GetValue("FieldOfView")))
    thisEntity:SaveBoolean("script.FOV2D", spawnkeys:GetValue("FOV2D"))
    thisEntity:SaveBoolean("script.test_occlusion", spawnkeys:GetValue("test_occlusion"))
    thisEntity:SaveString("script.LookFromClass", spawnkeys:GetValue("LookFromClass") or look_from_class)
    thisEntity:SaveString("script.LookFromName", spawnkeys:GetValue("LookFromName") or look_from_name)
    thisEntity:SaveString("script.LookFromAttachment", spawnkeys:GetValue("LookFromAttachment") or look_from_attachment_name)
    thisEntity:SaveBoolean("script.CheckAllTargets", spawnkeys:GetValue("CheckAllTargets") == 1)

    thisEntity:RedirectOutput("OnStartTouchAll", "OnStartTouchAll", thisEntity)
    thisEntity:RedirectOutput("OnEndTouchAll", "OnEndTouchAll", thisEntity)
end


-- Game load fix

local function ready(saveLoaded)
    target_name = thisEntity:LoadString("script.target")
    look_time = thisEntity:LoadNumber("script.LookTime")
    fov = thisEntity:LoadNumber("script.FieldOfView")
    use_2d = thisEntity:LoadBoolean("script.FOV2D")
    test_occlusion = thisEntity:LoadBoolean("script.test_occlusion")
    look_from_class = thisEntity:LoadString("script.LookFromClass")
    look_from_name = thisEntity:LoadString("script.LookFromName")
    look_from_attachment_name = thisEntity:LoadString("script.LookFromAttachment")
    check_all_targets = thisEntity:LoadBoolean("script.CheckAllTargets")
end

-- Fix for script executing twice on restore.
-- This binds to the new local ready function on second execution.
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
