
---@param activateType "0"|"1"|"2"
function Activate(activateType)
    print("Bonemerge script activated", thisEntity:GetName())
    ListenToGameEvent("npc_ragdoll_created", NpcRagdollCreated, thisEntity)
end

function NpcRagdollCreated(_, data)
    if thisEntity:entindex() == data.npc_entindex then
        local npc = EntIndexToHScript(data.npc_entindex)
        local ragdoll = EntIndexToHScript(data.ragdoll_entindex)
        -- first try to replace ragdoll
        print("Looking for bonemerge")
        for _, child in ipairs(npc:GetChildren()) do
            if vlua.find(child:GetName(), "bonemerge", 1) then
                print("Found bonemerge", child:GetModelName())
                --ragdoll:SetModel(child:GetModelName())
                local prop = SpawnEntityFromTableSynchronous("prop_dynamic", {
                    --origin = thisEntity:GetOrigin(),
                    --angles = thisEntity:GetAngles(),
                    --scales = "4.05 4.05 4.05",
                    model = child:GetModelName(),
                    solid = "0"
                })
                prop:SetParent(ragdoll, "!bonemerge")
                ragdoll:SetRenderAlpha(0)
            end
        end
        StopListeningToAllGameEvents(thisEntity)

        
        --[[ local vel = GetPhysVelocity(ragdoll)
        local ang = GetPhysAngularVelocity(ragdoll)
        SetPhysAngularVelocity(prop, ang*2)
        prop:ApplyAbsVelocityImpulse(vel*2)
        ragdoll:Kill()
        StopListeningToAllGameEvents(thisEntity)
        thisEntity:Kill() ]]
    end
end
