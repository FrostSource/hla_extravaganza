--[[
    v1.0.0
    https://github.com/FrostSource/hla_extravaganza

    Extension for NPC entities.
    Some functions are specific to only one entity class such as `npc_combine_s`, check the individual function descriptions.

    If not using `vscripts/core.lua`, load this file at game start using the following line:
    
    ```lua
    require "extensions.npc"
    ```
]]

require "extensions.entity"
require "extensions.entities"

local version = "v1.0.0"

---
---Schedule enum table for use with CAI_BaseNPC:StartSchedule().
---
Schedule = {
    ---@enum ScheduleType
    Type = {
        None = 0,
        WalkToGoalEntity = 1,
        RunToGoalEntity = 2,
        SetEnemyToGoalEntity = 3,
        WalkGoalPath = 4,
        RunGoalPath = 5,
        SetEnemyToGoalEntityANDRunToGoalEntity = 6,
        SetEnemyToGoalEntityANDWalkToGoalEntity = 7,
    },
    ---@enum ScheduleState
    State = {
        None = 0,
        Idle = 1,
        Alert = 2,
        Combat = 3,
    },
    ---@enum ScheduleInterruptability
    Interruptability = {
        General = 0,
        DamageOrDeath = 1,
        Death = 2,
        Combat = 3,
    }
}

---
---Create and start a new schedule for this NPC.
---
---@param state ScheduleState # The NPC state that should be set.
---@param type ScheduleType # The type of schedule to perform.
---@param interruptability ScheduleInterruptability # What should interrupt the NPC from the schedule.
---@param reacquire boolean # If the NPC should reacquire the schedule after being interrupted.
---@param goal EntityHandle|Vector # Worldspace position or entity goal (entity origin will be used).
---@return EntityHandle # The schedule entity.
function CAI_BaseNPC:StartSchedule(state, type, interruptability, reacquire, goal)

    local goalName

    if IsVector(goal) then
        goalName = DoUniqueString("schedule_positional_target")
    else
        goalName = goal:GetName()
    end

    local schedule = SpawnEntityFromTableSynchronous("aiscripted_schedule", {
        m_iszEntity = self:GetName(),
        schedule = type,
        forcestate = state,
        interruptability = interruptability,
        resilient = reacquire,
        goalent = goalName,
    })

    if IsVector(goal) then
        local target = SpawnEntityFromTableSynchronous("info_target", {
            origin = goal,
            targetname = goalName
        })
        -- parent target to schedule so it will be killed when schedule is
        target:SetParent(schedule, "")
    end

    schedule:EntFire("StartSchedule")

    return schedule

end

---
---Stops the given schedule for this NPC.
---
---@param schedule EntityHandle # The previously created schedule.
---@param dontKill? boolean # If true the schedule will not be killed at the same time.
function CAI_BaseNPC:StopSchedule(schedule, dontKill)
    if IsEntity(schedule, true) then
        schedule:EntFire("StopSchedule")
        if not dontKill then
            schedule:EntFire("Kill")
        end
    end
end

---Set state of the NPC.
---@param state ScheduleState
function CAI_BaseNPC:SetState(state)
    local schedule = self:StartSchedule(state, 0, 0, false, self)
end

---
---Get if this combine has an enemy target.
---
---This function only works with `npc_combine_s` entities.
---@return boolean # True if the combine has an enemy.
function CAI_BaseNPC:HasEnemyTarget()
    return self:GetGraphParameter('f_enemy_distance') ~= -1
end

---
---Estimate the nearest enemy that this combine is fighting using its animgraph parameters.
---
---This function only works with `npc_combine_s` entities.
---
---**NOTE: This function will not work correctly without a modified version of the combine animgraph that extends the maximum enemy distance!**
---
---@param maxRadius number # Maximum radius to estimate around. Default = 64.
---@return EntityHandle? # Estimated enemy target.
function CAI_BaseNPC:EstimateEnemyTarget(maxRadius)
    local heading = self:GetGraphParameter('f_enemy_heading')
    local distance = self:GetGraphParameter('f_enemy_distance')
    local at = self:GetOrigin() + RotatePosition(Vector(), QAngle(0, heading, 0), self:GetForwardVector()) * distance
    return Entities:FindNearest(at, maxRadius or 64)
end

