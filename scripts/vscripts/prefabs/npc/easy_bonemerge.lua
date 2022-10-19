--[[
    v2.0.0
    https://github.com/FrostSource/hla_extravaganza

    Prefab specific functions for maps/prefabs/logic/logic_weighted_random/logic_weighted_random.vmap
]]

local listener

---
---Rebinds the bonemerged prop to the new ragdoll.
---
---@param data GAME_EVENT_NPC_RAGDOLL_CREATED
local function NpcRagdollCreated(data)
    if not IsValidEntity(thisEntity) then
        StopListeningToGameEvent(listener)
        return
    end
    -- Check if the npc that died is THIS npc
    if thisEntity:entindex() ~= data.npc_entindex then
        return
    end
    -- Stop listening to this game event. Without this errors may occur.
    StopListeningToGameEvent(listener)
    -- Resolve npc/ragdoll index to handles
    local npc = EntIndexToHScript(data.npc_entindex)--[[@as EntityHandle]]
    local ragdoll = EntIndexToHScript(data.ragdoll_entindex)--[[@as EntityHandle]]
    -- Checking for a child with name "bonemerge" to know which model to use
    for _, child in ipairs(npc:GetChildren()) do
        if vlua.find(child:GetName(), 'bonemerger') then
            child:SetParent(ragdoll, '!bonemerge')
            ragdoll:SetRenderAlpha(0)
        end
    end
end

---
---Templated ents have an issue where the script runs but the entity doesn't activate.
---If we listen outside of activations we will encounter errors.
---
---@param activateType 0|1|2
function Activate(activateType)
    listener = ListenToGameEvent('npc_ragdoll_created', NpcRagdollCreated, nil)
end

