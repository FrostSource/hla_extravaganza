> Last Updated 2023-12-01

## Index
1. [entities.lua](#entitieslua)
2. [entity.lua](#entitylua)
3. [npc.lua](#npclua)
4. [string.lua](#stringlua)
5. [vector.lua](#vectorlua)

---

# entities.lua

> v1.5.0

Extensions for the `Entities` class. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "extensions.entities"
```


## Functions

<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`Entities:All()`</td><td> Gets an array of every entity that currently exists. </td></tr><tr><td>

`Entities:Random()`</td><td> Gets a random entity in the map. </td></tr><tr><td>

`Entities:FindInPrefab(entity, name)`</td><td> Find an entity within the same prefab as another entity.  Will have issues in nested prefabs. </td></tr><tr><td>

`CEntityInstance:FindInPrefab(name)`</td><td> Find an entity within the same prefab as this entity.  Will have issues in nested prefabs. </td></tr><tr><td>

`Entities:FindAllInCone(origin, direction, maxDistance, maxAngle, checkEntityBounds)`</td><td> Find all entities with a cone. </td></tr><tr><td>

`Entities:FindAllInBounds(mins, maxs, checkEntityBounds)`</td><td> Find all entities within `mins` and `maxs` bounding box. </td></tr><tr><td>

`Entities:FindAllInBox(width, length, height)`</td><td> Find all entities within an `origin` centered box. </td></tr><tr><td>

`Entities:FindAllInCube(origin, size)`</td><td> Find all entities within an `origin` centered cube of a given `size.` </td></tr><tr><td>

`Entities:FindNearest(origin, maxRadius)`</td><td> Find the nearest entity to a world position. </td></tr></table>



---

# entity.lua

> v2.3.0

Provides base entity extension methods. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "extensions.entity"
```


## Functions

<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`CBaseEntity:GetTopChildren()`</td><td> Get the top level entities parented to this entity. Not children of children. </td></tr><tr><td>

`CBaseEntity:EntFire(action, value, delay, activator, caller)`</td><td> Send an input to this entity. </td></tr><tr><td>

`CBaseEntity:GetFirstChildWithClassname(classname)`</td><td> Get the first child in this entity's hierarchy with a given classname. </td></tr><tr><td>

`CBaseEntity:GetFirstChildWithName(name)`</td><td> Get the first child in this entity's hierarchy with a given target name. </td></tr><tr><td>

`CBaseEntity:SetQAngle(qangle)`</td><td> Set entity pitch, yaw, roll from a `QAngle`. </td></tr><tr><td>

`CBaseEntity:SetLocalQAngle(qangle)`</td><td> Set entity local pitch, yaw, roll from a `QAngle`. </td></tr><tr><td>

`CBaseEntity:SetAngle(pitch, yaw, roll)`</td><td> Set entity pitch, yaw or roll. Supply `nil` for any parameter to leave it unchanged. </td></tr><tr><td>

`CBaseEntity:ResetLocal()`</td><td> Resets local origin and angle to [0,0,0] </td></tr><tr><td>

`CBaseEntity:GetSize()`</td><td> Get the bounding size of the entity. </td></tr><tr><td>

`CBaseEntity:GetBiggestBounding()`</td><td> Get the biggest bounding box axis of the entity. This will be `size.x`, `size.y` or `size.z`. </td></tr><tr><td>

`CBaseEntity:GetRadius()`</td><td> Get the radius of the entity bounding box. This is half the size of the sphere. </td></tr><tr><td>

`CBaseEntity:GetVolume()`</td><td> Get the volume of the entity bounds in inches cubed. </td></tr><tr><td>

`CBaseEntity:GetBoundingCorners(rotated)`</td><td> Get each corner of the entity's bounding box. </td></tr><tr><td>

`CBaseEntity:IsWithinBounds(mins, maxs, checkEntityBounds)`</td><td> Check if entity is within the given worldspace bounds. </td></tr><tr><td>

`CBaseEntity:DisablePickup()`</td><td> Send the `DisablePickup` input to the entity. </td></tr><tr><td>

`CBaseEntity:EnablePickup()`</td><td> Send the `EnablePickup` input to the entity. </td></tr><tr><td>

`CBaseEntity:Delay(func, delay)`</td><td> Delay some code using this entity. </td></tr><tr><td>

`CBaseEntity:GetParents()`</td><td> Get all parents in the hierarchy upwards. </td></tr><tr><td>

`CBaseEntity:DoNotDrop(enabled)`</td><td> Set if the prop is allowed to be dropped. Only works for physics based props. </td></tr><tr><td>

`CBaseEntity:GetCriteria()`</td><td> Get all criteria as a table. </td></tr><tr><td>

`CBaseEntity:GetOwnedEntities()`</td><td> Get all entities which are owned by this entity  **Note:** This searches all entities in the map and should be used sparingly.</td></tr><tr><td>

`CBaseModelEntity:SetRenderAlphaAll(alpha)`</td><td> Set the alpha modulation of this entity, plus any children that can have their alpha set. </td></tr><tr><td>

`CBaseEntity:SetCenter(position)`</td><td> Center the entity at a new position. </td></tr><tr><td>

`CBaseEntity:TrackProperty(propertyFunction, onChangeFunction, interval, context)`</td><td> Track a property function using a callback when a change is detected.      -- Make entity fully opaque if alpha is ever detected below 255     thisEntity:TrackProperty(thisEntity.GetRenderAlpha, function(prevValue, newValue)         if newValue < 255 then             thisEntity:SetRenderAlpha(255)         end     end) </td></tr><tr><td>

`CBaseEntity:UntrackProperty(propertyFunction)`</td><td>  Untrack a property function which was set to be tracked using `CBaseEntity:TrackProperty`. </td></tr></table>



---

# npc.lua

> v1.0.0

Extension for NPC entities. Some functions are specific to only one entity class such as `npc_combine_s`, check the individual function descriptions. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "extensions.npc"
```


## Functions

<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`CAI_BaseNPC:StartSchedule(state, type, interruptability, reacquire, goal)`</td><td> Create and start a new schedule for this NPC. </td></tr><tr><td>

`CAI_BaseNPC:StopSchedule(schedule, dontKill)`</td><td> Stops the given schedule for this NPC. </td></tr><tr><td>

`CAI_BaseNPC:SetState(state)`</td><td>Set state of the NPC.</td></tr><tr><td>

`CAI_BaseNPC:HasEnemyTarget()`</td><td> Get if this NPC has an enemy target.  This function only works with entities that have `enemy` or `distancetoenemy` criteria. </td></tr><tr><td>

`CAI_BaseNPC:EstimateEnemyTarget(distanceTolerance)`</td><td> Estimate the enemy that this NPC is fighting using its criteria values.  This function only works with entities that have `enemy` criteria; "npc_combine_s", "npc_zombine", "npc_zombie_blind". </td></tr><tr><td>

`CAI_BaseNPC:SetRelationship(target, disposition, priority)`</td><td>Set the relationship of this NPC with a targetname or classname.</td></tr></table>



---

# string.lua

> v1.3.0

Provides string class extension methods. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "extensions.string"
```


## Functions

<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`string.startswith(s, substr)`</td><td> Gets if a string starts with a substring.</td></tr><tr><td>

`string.endswith(s, substr)`</td><td> Gets if a string ends with a substring. </td></tr><tr><td>

`string.splitraw(s, pattern)`</td><td> Split an input string using a raw pattern string. No changes are made to the pattern. </td></tr><tr><td>

`string.split(s, sep)`</td><td> Split an input string using a separator string.  </td></tr><tr><td>

`string.truncate(s, len, replacement)`</td><td> Truncates a string to a maximum length. If the string is shorter than `len` the original string is returned. </td></tr><tr><td>

`string.trimleft(s, char)`</td><td> Trims characters from the left side of the string up to the last occurrence of a specified character. </td></tr><tr><td>

`string.trimright(s, char)`</td><td> Trims characters from the right side of the string up to the last occurrence of a specified character. </td></tr><tr><td>

`string.capitalize(s, only_first_letter)`</td><td> Capitalizes letters in the input string. If `onlyFirstLetter` is true, it capitalizes only the first letter. If `onlyFirstLetter` is false or not provided, it capitalizes all letters. </td></tr></table>



---

# vector.lua

> v1.2.0

Provides Vector class extension methods. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "extensions.vector"
```


## Functions

<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`meta:Perpendicular()`</td><td> Calculates the perpendicular vector to the current vector. </td></tr><tr><td>

`meta:IsPerpendicularTo(vector, tolerance)`</td><td> Check if the current vector is perpendicular to another vector. </td></tr><tr><td>

`meta:IsParallelTo(vector)`</td><td> Checks if the current vector is parallel to the given vector. </td></tr><tr><td>

`meta:Slerp(target, t)`</td><td> Spherical linear interpolation between the calling vector and the target vector over t = [0, 1]. </td></tr><tr><td>

`meta:LocalTranslate(offset, forward, right, up)`</td><td> Translates the vector in a local coordinate system. </td></tr><tr><td>

`meta:AngleDiff(vector)`</td><td> Calculates the angle difference between the calling vector and the given vector. This is always the smallest angle. </td></tr><tr><td>

`meta:SignedAngleDiff()`</td><td> Calculates the signed angle difference between the calling vector and the given vector around the specified axis.   @param vector Vector # The vector to calculate the angle difference with.  @param axis? Vector # The axis of rotation around which the angle difference is calculated.  @return number # The signed angle difference in degrees.</td></tr><tr><td>

`meta:Unpack()`</td><td> Unpacks the x, y, z components as 3 return values. </td></tr><tr><td>

`meta:LengthSquared()`</td><td> Returns the squared length of the vector, without using sqrt. </td></tr></table>



