> Last Updated 2022-11-07

---

# entities.lua (v1.2.0)

Extensions for the `Entities` class. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "extensions.entities"
```


<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`Entities:All()`</td><td> Gets an array of every entity that currently exists. </td></tr><tr><td>

`Entities:Random()`</td><td> Gets a random entity in the map. </td></tr><tr><td>

`Entities:FindInPrefab(entity, name)`</td><td> Find an entity within the same prefab as another entity.  Will have issues in nested prefabs. </td></tr><tr><td>

`CEntityInstance:FindInPrefab(name)`</td><td> Find an entity within the same prefab as this entity.  Will have issues in nested prefabs. </td></tr></table>



---

# entity.lua (v1.1.1)

Provides base entity extension methods. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "extensions.entity"
```


<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`CBaseEntity:GetTopChildren()`</td><td> Get the top level entities parented to this entity. Not children of children. </td></tr><tr><td>

`CBaseEntity:EntFire(action, value, delay, activator, caller)`</td><td> Send an input to this entity. </td></tr><tr><td>

`CBaseEntity:GetFirstChildWithClassname(classname)`</td><td> Get the first child in this entity's hierarchy with a given classname. </td></tr><tr><td>

`CBaseEntity:GetFirstChildWithName(name)`</td><td> Get the first child in this entity's hierarchy with a given target name. </td></tr><tr><td>

`CBaseEntity:SetAngle(qangle)`</td><td> Set entity pitch, yaw, roll from a `QAngle`. </td></tr><tr><td>

`CBaseEntity:GetBiggestBounding()`</td><td> Gets the biggest bounding box axis of the entity. </td></tr><tr><td>

`CBaseEntity:DisablePickup()`</td><td> Sends the `DisablePickup` input to the entity. </td></tr><tr><td>

`CBaseEntity:EnablePickup()`</td><td>Sends the `EnablePickup` input to the entity. </td></tr><tr><td>

`CBaseEntity:Delay(func, delay)`</td><td> Delay some code using this entity. </td></tr><tr><td>

`CBaseEntity:GetParents()`</td><td> Gets all parents in the hierarchy upwards. </td></tr><tr><td>

`CBaseEntity:DoNotDrop(enabled)`</td><td> Set if the prop is allowed to be dropped. Only works for physics based props. </td></tr></table>



---

# string.lua (v1.1.1)

Provides string class extension methods. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "extensions.string"
```


<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`string:startswith(substr)`</td><td> Gets if a string starts with a substring. </td></tr><tr><td>

`string:endswith(substr)`</td><td> Gets if a string ends with a substring. </td></tr><tr><td>

`string:split(sep)`</td><td> Split an input string using a separator string.  Found at https://stackoverflow.com/a/7615129 </td></tr><tr><td>

`string:truncate(len, replacement)`</td><td> Truncates a string to a maximum length. If the string is shorter than `len` the original string is returned. </td></tr></table>



