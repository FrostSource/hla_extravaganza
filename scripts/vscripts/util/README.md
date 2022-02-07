# util <!-- omit in toc -->

> Utility scripts and libraries for extending base functionality of Alyx. These are typically loaded into the global scope and will explicitly mention if loaded another way. If a library is dependant on another library it will be stated at the very bottom of the file's header comment, for example in `player.lua`:

```lua
require "util.util"
require "util.storage"
```

> Each script will have a more detailed description of how it works inside.

<sup>TODO: Add member scraping alongside function scraping.</sup>
<sup>TODO: Add folder and description scraping to fully automate this list.</sup>

- [utilinit.lua](#utilinitlua)
- [Global Utility Libraries](#global-utility-libraries)
  - [util.lua](#utillua)
  - [storage.lua](#storagelua)
  - [debug.lua](#debuglua)
  - [enums.lua](#enumslua)
- [Class Extensions](#class-extensions)
  - [player.lua](#playerlua)
- [Data Type Libraries](#data-type-libraries)
  - [weighted_random.lua](#weighted_randomlua)
  - [stack.lua](#stacklua)
  - [queue.lua](#queuelua)
  - [inventory.lua](#inventorylua)

## utilinit.lua

This file is an easy way to load all util scripts into the global scope:

```lua
require "util.utilinit"
```

## Global Utility Libraries

### util.lua
The main utility script, very often used by other scripts, providing useful general functions that don't belong to any specific classes.
```lua
require "util.util
```
<table><thead><tr><th>Function</th><th>Description</th></tr></thead><tbody><tr><td width="65%"><code>string GetScriptFile(string <i>sep?</i>)</code></td><td>Get the file name of the current script without folders or extension. E.g. `util.util`</td></tr><tr><td width="65%"><code>bool IsEntity(any|handle <i>handle</i>)</code></td><td>Get if the given `handle` value is an entity, regardless of if it's still alive.</td></tr><tr><td width="65%"><code>void AddOutput(handle <i>handle</i>, string <i>output</i>, string|handle <i>target</i>, string <i>input</i>, string <i>parameter?</i>, float <i>delay?</i>, handle <i>activator?</i>, handle <i>caller?</i>, bool <i>fireOnce?</i>)</code></td><td>Add an output to a given entity `handle`.</td></tr><tr><td width="65%"><code>float util.GetHandIdFromTip(float <i>vr_tip_attachment</i>)</code></td><td>Convert vr_tip_attachment from a game event [1,2] into a hand id [0,1] taking into account left handedness.</td></tr><tr><td width="65%"><code>handle util.EstimateNearestEntity(string <i>name</i>, string <i>class</i>, CBaseEntity <i>position</i>, float <i>radius?</i>)</code></td><td>Estimates the nearest entity `position` with the targetname of `name` (or classname `class` if the name is blank).</td></tr><tr><td width="65%"><code>void util.PrintTable(table <i>tbl</i>, string <i>prefix?</i>)</code></td><td>Prints the keys/values of a table and any tested tables. <br>This is different from `DeepPrintTable` in that it will not print members of entity handles.</td></tr><tr><td width="65%"><code>handle util.GetFirstChildWithClassname(handle <i>handle</i>, string <i>classname</i>)</code></td><td>Get the first child in an entity's hierarchy with a given classname.</td></tr><tr><td width="65%"><code>handle util.GetFirstChildWithName(handle <i>handle</i>, string <i>name</i>)</code></td><td>Get the first child in an entity's hierarchy with a given target name.</td></tr><tr><td width="65%"><code>string util.FindKeyFromValue(table <i>tbl</i>, any <i>value</i>)</code></td><td>Attempt to find a key in `tbl` pointing to `value`.</td></tr><tr><td width="65%"><code>string util.FindKeyFromValueDeep(table <i>tbl</i>, any <i>value</i>)</code></td><td>Attempt to find a key in `tbl` pointing to `value` by recursively searching nested tables.</td></tr><tr><td width="65%"><code>void util.SanitizeFunctionForHammer(function <i>func</i>, string <i>name?</i>, table <i>scope?</i>)</code></td><td>Add a function to the global scope with alternate casing styles. Makes a function easier to call from Hammer through I/O.</td></tr><tr><td width="65%"><code>int util.TableSize(table <i>tbl</i>)</code></td><td>Returns the size of any table.</td></tr><tr><td width="65%"><code>any util.RemoveFromTable(table <i>tbl</i>, any <i>value</i>)</code></td><td>Remove a value from a table, returning it if it exists.</td></tr><tr><td width="65%"><code>string[] util.SplitString(string <i>inputstr</i>, string <i>sep</i>)</code></td><td>Split an input string using a separator string. <br>Found at https://stackoverflow.com/a/7615129</td></tr><tr><td width="65%"><code>void util.AppendArray(any[] <i>array1</i>, any[] <i>array2</i>)</code></td><td>Appends `array2` onto `array1` as a new array. Safe extend function alternative to `vlua.extend`.</td></tr><tr><td width="65%"><code>void util.Delay(function <i>func</i>,  <i>delay</i>)</code></td><td>Delay some code.</td></tr><tr><td width="65%"><code>float|string util.math.sign(float <i>number</i>)</code></td><td>Get the sign of a number.</td></tr></tbody></table>

### storage.lua
Provides functionality for saving data types allowing you to retrieve them again on game load. 
```lua
require "util.storage
```
<table><thead><tr><th>Function</th><th>Description</th></tr></thead><tbody><tr><td width="65%"><code>bool Storage.SaveString(handle <i>handle</i>, string <i>name</i>, string <i>value</i>)</code></td><td>Save a string.</td></tr><tr><td width="65%"><code>bool Storage.SaveNumber(handle <i>handle</i>, string <i>name</i>, float <i>value</i>)</code></td><td>Save a number.</td></tr><tr><td width="65%"><code>bool Storage.SaveBoolean(handle <i>handle</i>, string <i>name</i>, bool <i>bool</i>)</code></td><td>Save a boolean.</td></tr><tr><td width="65%"><code>bool Storage.SaveVector(handle <i>handle</i>, string <i>name</i>, Vector <i>vector</i>)</code></td><td>Save a Vector.</td></tr><tr><td width="65%"><code>bool Storage.SaveQAngle(handle <i>handle</i>, string <i>name</i>, QAngle <i>qangle</i>)</code></td><td>Save a QAngle.</td></tr><tr><td width="65%"><code>bool Storage.SaveTable(handle <i>handle</i>, string <i>name</i>, table<any,any> <i>tbl</i>)</code></td><td>Save a table. <br>May be ordered, unordered or mixed. <br>May have nested tables.</td></tr><tr><td width="65%"><code>bool Storage.SaveEntity(handle <i>handle</i>, string <i>name</i>, handle <i>entity</i>)</code></td><td>Save an entity reference. <br>Entity handles change between game sessions so this function modifies the passed entity to make sure it can keep track of it.</td></tr><tr><td width="65%"><code>bool Storage.Save(handle <i>handle</i>, string <i>name</i>, any <i>value</i>)</code></td><td>Save a value. <br>Uses type inference to save the value. If you are experiencing errors consider saving with one of the explicit type saves.</td></tr><tr><td width="65%"><code>string Storage.LoadString(handle <i>handle</i>, string <i>name</i>, string <i>default?</i>)</code></td><td>Load a string.</td></tr><tr><td width="65%"><code>float Storage.LoadNumber(handle <i>handle</i>, string <i>name</i>, float <i>default?</i>)</code></td><td>Load a number.</td></tr><tr><td width="65%"><code>bool Storage.LoadBoolean(handle <i>handle</i>, string <i>name</i>, bool <i>default?</i>)</code></td><td>Load a boolean value.</td></tr><tr><td width="65%"><code>Vector Storage.LoadVector(handle <i>handle</i>, string <i>name</i>, Vector <i>default?</i>)</code></td><td>Load a Vector.</td></tr><tr><td width="65%"><code>QAngle Storage.LoadQAngle(handle <i>handle</i>, string <i>name</i>, QAngle <i>default?</i>)</code></td><td>Load a QAngle.</td></tr><tr><td width="65%"><code>void Storage.LoadTable(handle <i>handle</i>, string <i>name</i>, table<any,any> <i>default</i>)</code></td><td>Load a table.</td></tr><tr><td width="65%"><code>handle Storage.LoadEntity(handle <i>handle</i>, string <i>name</i>, handle <i>default</i>)</code></td><td>Load an entity.</td></tr><tr><td width="65%"><code>any Storage.Load(handle <i>handle</i>, string <i>name</i>, any <i>default?</i>)</code></td><td>Load a value.</td></tr></tbody></table>

### debug.lua
Provides helpful debugging functions when testing your map and scripts.
```lua
require "util.debug"
```
<table><thead><tr><th>Function</th><th>Description</th></tr></thead><tbody><tr><td width="65%"><code>void Debug.PrintEntityList(EntityHandle[] <i>list</i>)</code></td><td>comment</td></tr><tr><td width="65%"><code>void Debug.PrintAllEntities()</code></td><td></td></tr><tr><td width="65%"><code>void Debug.PrintAllEntitiesInSphere( <i>origin</i>,  <i>radius</i>)</code></td><td></td></tr></tbody></table>

### enums.lua
Adds missing enumeration names to the global scope. See an example of missing enums here https://developer.valvesoftware.com/wiki/Half-Life_Alyx_Scripting_API#Controller_types
```lua
require "util.enums"
```

## Class Extensions

### player.lua
Player script allows for more advanced player manipulation and easier entity access for player related entities by extending the player class.
Useful Player methods are replicated as global functions so they can easily be invoked in Hammer using `CallGlobalScriptFunction` or `!player`>`CallScriptFunction`.
Attempts to track player items as well as the currently/previously held props for each hand.
```lua
require "util.player"
```
<table><thead><tr><th>Function</th><th>Description</th></tr></thead><tbody><tr><td width="65%"><code>void CBasePlayer:DropByHandle(CBaseEntity <i>handle</i>)</code></td><td>Force the player to drop an entity if held.</td></tr><tr><td width="65%"><code>void CBasePlayer:DropLeftHand()</code></td><td>Force the player to drop any item held in their left hand.</td></tr><tr><td width="65%"><code>void CBasePlayer:DropRightHand()</code></td><td>Force the player to drop any item held in their right hand.</td></tr><tr><td width="65%"><code>void CBasePlayer:DropPrimaryHand()</code></td><td>Force the player to drop any item held in their primary hand.</td></tr><tr><td width="65%"><code>void CBasePlayer:DropSecondaryHand()</code></td><td>Force the player to drop any item held in their secondary/off hand.</td></tr><tr><td width="65%"><code>void CBasePlayer:DropCaller(TypeIOInvoke <i>data</i>)</code></td><td>Force the player to drop the caller entity if held.</td></tr><tr><td width="65%"><code>void CBasePlayer:DropActivator(TypeIOInvoke <i>data</i>)</code></td><td>Force the player to drop the activator entity if held.</td></tr><tr><td width="65%"><code>void CBasePlayer:GrabByHandle(handle <i>handle</i>, CPropVRHand|float <i>hand?</i>)</code></td><td>Force the player to grab `handle` with `hand`.</td></tr><tr><td width="65%"><code>void CBasePlayer:GrabCaller(TypeIOInvoke <i>data</i>)</code></td><td>Force the player to grab the caller entity.</td></tr><tr><td width="65%"><code>void CBasePlayer:GrabActivator(TypeIOInvoke <i>data</i>)</code></td><td>Force the player to grab the activator entity.</td></tr><tr><td width="65%"><code>string CBasePlayer:GetMoveType()</code></td><td>Get VR movement type.</td></tr><tr><td width="65%"><code>handle CBasePlayer:GetLookingAt(float <i>maxDistance?</i>)</code></td><td>Returns the entity the player is looking at directly.</td></tr><tr><td width="65%"><code>void CBasePlayer:DisableFallDamage()</code></td><td>Disables fall damage for the player.</td></tr><tr><td width="65%"><code>void CBasePlayer:EnableFallDamage()</code></td><td>Enables fall damage for the player.</td></tr><tr><td width="65%"><code>void CBasePlayer:AddResources(float <i>pistol_ammo?</i>, float <i>rapidfire_ammo?</i>, float <i>shotgun_ammo?</i>, float <i>resin?</i>)</code></td><td>Adds resources to the player.</td></tr><tr><td width="65%"><code>void CBasePlayer:AddPistolAmmo(float <i>amount</i>)</code></td><td>Add pistol ammo to the player.</td></tr><tr><td width="65%"><code>void CBasePlayer:AddShotgunAmmo(float <i>amount</i>)</code></td><td>Add shotgun ammo to the player.</td></tr><tr><td width="65%"><code>void CBasePlayer:AddRapidfireAmmo(float <i>amount</i>)</code></td><td>Add rapidfire ammo to the player.</td></tr><tr><td width="65%"><code>void CBasePlayer:AddResin(float <i>amount</i>)</code></td><td>Add resin to the player.</td></tr><tr><td width="65%"><code>void CBasePlayer:MergePropWithHand(CPropVRHand|float <i>hand</i>, string|handle <i>prop</i>, bool <i>hide_hand</i>)</code></td><td>Marges an existing prop with a given hand.</td></tr><tr><td width="65%"><code>bool CBasePlayer:HasWeaponEquipped()</code></td><td>Return if the player has a gun equipped.</td></tr><tr><td width="65%"><code>float CBasePlayer:GetCurrentWeaponReserves()</code></td><td>Get the amount of ammo stored in the backpack for the currently equipped weapon.</td></tr><tr><td width="65%"><code>bool CBasePlayer:HasItemHolder()</code></td><td>Player has item holder equipped.</td></tr><tr><td width="65%"><code>bool CBasePlayer:HasGrabbityGloves()</code></td><td>Player has grabbity gloves equipped.</td></tr><tr><td width="65%"><code>void CBasePlayer:GetFlashlight()</code></td><td></td></tr><tr><td width="65%"><code>Vector CBasePlayer:GetFlashlightPointedAt(float <i>maxDistance</i>)</code></td><td>Get the first entity the flashlight is pointed at (if the flashlight exists).</td></tr><tr><td width="65%"><code>void RegisterPlayerEventCallback(string <i>event</i>, function <i>callback</i>)</code></td><td>Register a callback function with for a player event.</td></tr><tr><td width="65%"><code>void UnregisterPlayerEventCallback(function <i>callback</i>)</code></td><td>Unregister a callback with a name.</td></tr><tr><td width="65%"><code>void CPropVRHand:MergeProp(string|handle <i>prop</i>, bool <i>hide_hand</i>)</code></td><td>Merge an existing prop with this hand.</td></tr><tr><td width="65%"><code>bool CPropVRHand:IsHoldingItem()</code></td><td>Return true if this hand is currently holding a prop.</td></tr><tr><td width="65%"><code>handle CPropVRHand:GetGrabbityGlove()</code></td><td>Get the entity for this hands grabbity glove.</td></tr><tr><td width="65%"><code>void CBaseEntity:Drop(CBaseEntity <i>self</i>)</code></td><td>Forces the player to drop this entity if held.</td></tr><tr><td width="65%"><code>void CBaseEntity:Grab()</code></td><td>Force the player to grab this entity with the nearest hand.</td></tr></tbody></table>

## Data Type Libraries

### weighted_random.lua
The WeightedRandom class allows you to assign chances to tables. Good for things like assigning rarity to item spawns.
```lua
require "util.weighted_random"
```
<table><thead><tr><th>Function</th><th>Description</th></tr></thead><tbody><tr><td width="65%"><code>void WeightedRandom:Add(table <i>tbl</i>, float <i>weight</i>)</code></td><td>Add a table value with an associated weight. <br>Note: The table `tbl` is not cloned, the given reference is used.</td></tr><tr><td width="65%"><code>float WeightedRandom:TotalWeight()</code></td><td>Get the total weight of this weighted random object.</td></tr><tr><td width="65%"><code>table WeightedRandom:Random()</code></td><td>Get a random table from the list of weighted tables.</td></tr><tr><td width="65%"><code>WeightedRandom WeightedRandom(table[]|string <i>weights</i>)</code></td><td>Create a new WeightedRandom object with given weights.</td></tr></tbody></table>

### stack.lua
Adds stack behaviour for tables with index 1 as the top of the stack.
```lua
require "util.stack"
```
<table><thead><tr><th>Function</th><th>Description</th></tr></thead><tbody><tr><td width="65%"><code>void Stack:Push(any <i>...</i>)</code></td><td>Push values to the stack.</td></tr><tr><td width="65%"><code>any Stack:Pop(float <i>count?</i>)</code></td><td>Pop a number of items from the stack.</td></tr><tr><td width="65%"><code>any Stack:Peek(float <i>count?</i>)</code></td><td>Peek at a number of items at the top of the stack without removing them.</td></tr><tr><td width="65%"><code>void Stack:Remove(any <i>value</i>)</code></td><td>Remove a value from the stack regardless of its position.</td></tr><tr><td width="65%"><code>bool Stack:MoveToTop(any <i>value</i>)</code></td><td>Move an existing value to the top of the stack. Only the first occurance will be moved.</td></tr><tr><td width="65%"><code>bool Stack:MoveToBottom(any <i>value</i>)</code></td><td>Move an existing value to the bottom of the stack. Only the first occurance will be moved.</td></tr><tr><td width="65%"><code>int Stack:Length()</code></td><td>Return the number of items in the stack.</td></tr><tr><td width="65%"><code>void Stack:IsEmpty()</code></td><td>Get if the stack is empty.</td></tr><tr><td width="65%"><code>bool Stack:Contains(any <i>value</i>)</code></td><td>Get if this stack contains a value.</td></tr><tr><td width="65%"><code>Stack Stack(any <i>...</i>)</code></td><td>Create a new `Stack` object. First value is at the top.</td></tr></tbody></table>

### queue.lua
Adds queue behaviour for tables with #queue.items being the front of the queue.
```lua
require "util.queue"
```
<table><thead><tr><th>Function</th><th>Description</th></tr></thead><tbody><tr><td width="65%"><code>void Queue:Enqueue(any <i>...</i>)</code></td><td>Add values to the queue in the order they appear.</td></tr><tr><td width="65%"><code>... Queue:Dequeue(float <i>count?</i>)</code></td><td>Get a number of values in reverse order of the queue.</td></tr><tr><td width="65%"><code>int Queue:Length()</code></td><td>Return the number of items in the queue.</td></tr><tr><td width="65%"><code>any Queue:Peek(float <i>count?</i>)</code></td><td>Peek at a number of items at the end of the queue without removing them.</td></tr><tr><td width="65%"><code>void Queue:Remove(any <i>value</i>)</code></td><td>Remove a value from the queue regardless of its position.</td></tr><tr><td width="65%"><code>bool Queue:MoveToBack(any <i>value</i>)</code></td><td>Move an existing value to the front of the queue. Only the first occurance will be moved.</td></tr><tr><td width="65%"><code>bool Queue:MoveToFront(any <i>value</i>)</code></td><td>Move an existing value to the bottom of the stack. Only the first occurance will be moved.</td></tr><tr><td width="65%"><code>bool Queue:Contains(any <i>value</i>)</code></td><td>Get if this queue contains a value.</td></tr><tr><td width="65%"><code>Queue Queue(any <i>...</i>)</code></td><td>Create a new `Queue` object. Last value is at the front of the queue.</td></tr></tbody></table>

### inventory.lua
An inventory is a table where each key has an integer value assigned to it. When a value hits 0 the key is removed from the table.
```lua
require "util.inventory"
```
<table><thead><tr><th>Function</th><th>Description</th></tr></thead><tbody><tr><td width="65%"><code>float Inventory:Add(any <i>key</i>, int <i>value?</i>)</code></td><td>Add a number of values to a key.</td></tr><tr><td width="65%"><code>float Inventory:Remove(any <i>key</i>, int <i>value?</i>)</code></td><td>Remove a number of values from a key.</td></tr><tr><td width="65%"><code>int Inventory:Get(any <i>key</i>)</code></td><td>Get the value associated with a key. This is *not* the same as `inv.items[key]`.</td></tr><tr><td width="65%"><code>int Inventory:Highest()</code></td><td>Get the key with the highest value and its value.</td></tr><tr><td width="65%"><code>int Inventory:Lowest()</code></td><td>Get the key with the lowest value and its value.</td></tr><tr><td width="65%"><code>bool Inventory:Contains(any <i>key</i>)</code></td><td>Get if the inventory contains a key with a value greater than 0.</td></tr><tr><td width="65%"><code>bool Inventory:IsEmpty()</code></td><td>Get if the inventory is empty.</td></tr><tr><td width="65%"><code>Inventory Inventory(table<any,integer> <i>starting_inventory</i>)</code></td><td>Create a new `Inventory` object. First value is at the top.</td></tr></tbody></table>

