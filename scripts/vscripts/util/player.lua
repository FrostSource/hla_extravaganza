
Player = Player or {}

---Forces the player to drop an entity if held.
---@param handle CBaseEntity
function Player:DropByHandle(handle)
    local dmg = CreateDamageInfo(handle, handle, Vector(0,0,0), Vector(0,0,0), 0, 2)
    handle:TakeDamage(dmg)
    DestroyDamageInfo(dmg)
end

---Forces the player to drop the caller entity if held.
---@param data table
function Player:DropByCaller(data)
    if data.caller then
        Player:DropByHandle(data.caller)
    end
end
