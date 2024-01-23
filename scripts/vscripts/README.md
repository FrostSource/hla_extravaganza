> Last Updated 2024-01-23

## Index
1. [class.lua](#classlua)
2. [core.lua](#corelua)
3. [player.lua](#playerlua)
4. [storage.lua](#storagelua)

---

# class.lua

> v2.0.0

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "class"
```


### Entity Classes 


NOTE: Entity classes are still early in development and documentation is sparse. 

The new `entity` function is designed to ease the creation of entity classes and all the trouble that comes with complex entity scripts. Instead of defining functions and variables in the private script scope we define them in a shared table class which is inherited by all entities using this class. 

The simplest example of the entity function is: 



```lua
---Define the entity class, which returns both the class (base) and entity handle (self).
---By "inheriting" EntityClass we get helpful code completion.
---@class EntityName : EntityClass
local base, self = entity("EntityName")
---This stops code executing a second time after a game load.
if self.Initiated then return end

---A variable is defined for the class.
base.class_variable = 1

---A function is defined for the class. This specific function is called automatically.
---@param loaded boolean
function base:OnReady(loaded)
    ---Reference a class variable, note that we use `self` instead of `base` here inside the function.
    self.class_variable = self.class_variable + 1
end
```


Entity scripts using this feature should *not* use `thisEntity` and instead use `self`. It's important to remember to define your class functions on the `base` class. Functions defined on `self` will not be inherited by other classes which inherit your class. 

Thinking is simplified, allowing you to define a base class think which can be paused/resumed and the state of which will be saved, meaning the think function will automatically resume after a game load: 



```lua
function base:OnReady(loaded)
    if not loaded then
        self:ResumeThink()
    end
end

function base:Think()
    if Time() > 50 then
        self:PauseThink()
        return
    end
    return 0
end
```


Like the think state, any fields defined in the `base`/`self` objects will be automatically loaded. Currently these values still need to be saved manually but this is done easily with the new save function: 



```lua
base.value = 1

function base:ChangeValue()
    self.value = self.value + 1
    self:Save()
end
```


## Functions

<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`inherit(script)`</td><td>Inherit an existing entity class which was defined using `entity` function.</td></tr><tr><td>

`entity(name, ...)`</td><td> Creates a new entity class.  If this is called in an entity attached script then the entity automatically inherits the class and the class inherits the entity's metatable.  The class is only created once so this can be called in entity attached scripts multiple times and all subsequent calls will return the already created class. </td></tr><tr><td>

`EntityClass:Set(name, value)`</td><td>Assign a new value to entity's field `name`. This also saves the field.</td></tr><tr><td>

`EntityClass:Output(output, func)`</td><td>Define a function to redirected to `output` on spawn.</td></tr><tr><td>

`printinherits(ent, nest)`</td><td>Prints all classes that `ent` inherits.</td></tr><tr><td>

`getvalvemeta(ent)`</td><td>Get the original metatable that Valve assigns to the entity.</td></tr><tr><td>

`getinherits(class)`</td><td>Get a list of all classes that `class` inherits. Does not include the Valve class; use getvalvemeta() for that.</td></tr><tr><td>

`isinstance(ent, class)`</td><td>Get if an `EntityClass` instance inherits a given `class`.</td></tr></table>



---

# core.lua

> v3.1.0

The main core script provides useful global functions as well as loading any standard libraries that it can find. 

The two main purposes are: 

1. Automatically load libraries to simplify the process for users.
2. Provide entity class functions to emulate OOP programming.


Load this script into the global scope using the following line: 



```lua
require "core"
```


## Functions

<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr></table>



---

# player.lua

> v4.1.0

Player script allows for more advanced player manipulation and easier entity access for player related entities by extending the player class. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "player"
```


This module returns the version string. 

### Usage 


Common method for referencing the player and related entities is: 



```lua
local player = Entities:GetLocalPlayer()
local hmd_avatar = player:GetHMDAvatar()
local left_hand = hmd_avatar:GetVRHand(0)
local right_hand = hmd_avatar:GetVRHand(1)
```


This script simplifies the above code significantly by automatically caching player entity handles when the player spawns and introducing the global variable 'Player' which references the base player entity: 



```lua
local player = Player
local hmd_avatar = Player.HMDAvatar
local left_hand = Player.LeftHand
local right_hand = Player.RightHand
```


Since this script extends the player entity class directly you can mix and match your scripting style without worrying that you're referencing the wrong player table. 



```lua
Entities:GetLocalPlayer() == Player
```


### Player Callbacks 


Many game events related to the player are used to track player activity and callbacks can be registered to hook into them the same way you would a game event: 



```lua
RegisterPlayerEventCallback("vr_player_ready", function(data)
    ---@cast data PLAYER_EVENT_VR_PLAYER_READY
    if data.game_loaded then
        -- Load data
    end
end)
```


Although most of the player events are named after the same game events, the data that is passed to the callback is pre-processed and extended to provide better context for the event: 



```lua
---@param data PLAYER_EVENT_ITEM_PICKUP
RegisterPlayerEventCallback("item_pickup", function(data)
    if data.hand == Player.PrimaryHand and data.item_name == "@gun" then
        data.item:DoNotDrop(true)
    end
end)
```


### Tracking Items 


The script attempts to track player items, both inventory and physically held objects. These can be accessed through several new player tables and variables. 

Below are a few of the new variables that point an entity handle that the player has interacted with: 



```lua
Player.PrimaryHand.WristItem
Player.PrimaryHand.ItemHeld
Player.PrimaryHand.LastItemDropped
```


The player might not be holding anything so remember to nil check: 



```lua
local item = Player.PrimaryHand.ItemHeld
if item then
    local primary_held_name = item:GetName()
end
```


The `Player.Items` table keeps track of the ammo and resin the player has in the backpack. One addition value tracked is `resin_found` which is the amount of resin the player has collected regardless of removing from backpack or spending on upgrades. 

## Functions

<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`CBasePlayer:DropByHandle(handle)`</td><td>Force the player to drop an entity if held.</td></tr><tr><td>

`CBasePlayer:DropLeftHand()`</td><td>Force the player to drop any item held in their left hand.</td></tr><tr><td>

`CBasePlayer:DropRightHand()`</td><td>Force the player to drop any item held in their right hand.</td></tr><tr><td>

`CBasePlayer:DropPrimaryHand()`</td><td>Force the player to drop any item held in their primary hand.</td></tr><tr><td>

`CBasePlayer:DropSecondaryHand()`</td><td>Force the player to drop any item held in their secondary/off hand.</td></tr><tr><td>

`CBasePlayer:DropCaller(data)`</td><td>Force the player to drop the caller entity if held.</td></tr><tr><td>

`CBasePlayer:DropActivator(data)`</td><td>Force the player to drop the activator entity if held.</td></tr><tr><td>

`CBasePlayer:GrabByHandle(handle, hand)`</td><td>Force the player to grab `handle` with `hand`.</td></tr><tr><td>

`CBasePlayer:GrabCaller(data)`</td><td>Force the player to grab the caller entity.</td></tr><tr><td>

`CBasePlayer:GrabActivator(data)`</td><td>Force the player to grab the activator entity.</td></tr><tr><td>

`CBasePlayer:GetMoveType()`</td><td>Get VR movement type.</td></tr><tr><td>

`CBasePlayer:GetLookingAt(maxDistance)`</td><td>Returns the entity the player is looking at directly.</td></tr><tr><td>

`CBasePlayer:DisableFallDamage()`</td><td>Disables fall damage for the player.</td></tr><tr><td>

`CBasePlayer:EnableFallDamage()`</td><td>Enables fall damage for the player.</td></tr><tr><td>

`CBasePlayer:AddResources(pistol_ammo, rapidfire_ammo, shotgun_ammo, resin)`</td><td>Adds resources to the player.</td></tr><tr><td>

`CBasePlayer:SetResources(pistol_ammo, rapidfire_ammo, shotgun_ammo, resin)`</td><td>Sets resources for the player.</td></tr><tr><td>

`CBasePlayer:SetItems(energygun_ammo, generic_pistol_ammo, rapidfire_ammo, shotgun_ammo, frag_grenades, xen_grenades, healthpens, resin)`</td><td>Set the items that player has manually. This is purely for scripting and does not modify the actual items the player has in game. Use `Player:AddResources` to modify in-game items.</td></tr><tr><td>

`CBasePlayer:AddPistolAmmo(amount)`</td><td> Add pistol ammo to the player. </td></tr><tr><td>

`CBasePlayer:AddShotgunAmmo(amount)`</td><td> Add shotgun ammo to the player. </td></tr><tr><td>

`CBasePlayer:AddRapidfireAmmo(amount)`</td><td> Add rapidfire ammo to the player. </td></tr><tr><td>

`CBasePlayer:AddResin(amount)`</td><td> Add resin to the player. </td></tr><tr><td>

`CBasePlayer:GetImmediateItems()`</td><td> Gets the items currently held or in wrist pockets. </td></tr><tr><td>

`CBasePlayer:GetGrenades()`</td><td> Gets the grenades currently held or in wrist pockets.  Use `#Player:GetGrenades()` to get number of grenades player has access to. </td></tr><tr><td>

`CBasePlayer:GetHealthPens()`</td><td> Gets the health pens currently held or in wrist pockets.  Use `#Player:GetHealthPens()` to get number of health pens player has access to. </td></tr><tr><td>

`CBasePlayer:MergePropWithHand(hand, prop, hide_hand)`</td><td> Marges an existing prop with a given hand. </td></tr><tr><td>

`CBasePlayer:HasWeaponEquipped()`</td><td> Return if the player has a gun equipped. </td></tr><tr><td>

`CBasePlayer:GetCurrentWeaponReserves()`</td><td>Get the amount of ammo stored in the backpack for the currently equipped weapon.</td></tr><tr><td>

`CBasePlayer:HasItemHolder()`</td><td>Player has item holder equipped.</td></tr><tr><td>

`CBasePlayer:HasGrabbityGloves()`</td><td>Player has grabbity gloves equipped.</td></tr><tr><td>

`CBasePlayer:GetFlashlight()`</td><td></td></tr><tr><td>

`CBasePlayer:GetFlashlightPointedAt(maxDistance)`</td><td>Get the first entity the flashlight is pointed at (if the flashlight exists). If flashlight does not exist, both returns will be `nil`.</td></tr><tr><td>

`CBasePlayer:GetResin()`</td><td>Gets the current resin from the player. This is can be more accurate than `Player.Items.resin` Calling this will update `Player.Items.resin`</td></tr><tr><td>

`CBasePlayer:IsHolding(entity)`</td><td>Gets if player is holding an entity in either hand.	</td></tr><tr><td>

`CBasePlayer:GetWeapon()`</td><td>Get the entity handle of the currently equipped weapon/item. If nothing is equipped this will return the primary hand entity.</td></tr><tr><td>

`CBasePlayer:GetWorldForward()`</td><td>Get the forward vector of the player in world space coordinates (z is zeroed).</td></tr><tr><td>

`CBasePlayer:UpdateWeapons(removes, set)`</td><td> Update player weapon inventory, both removing and setting. </td></tr><tr><td>

`CBasePlayer:RemoveWeapons(weapons)`</td><td> Remove weapons from the player inventory. </td></tr><tr><td>

`CBasePlayer:SetWeapon(weapon)`</td><td> Set the weapon that the player is holding. </td></tr><tr><td>

`CBasePlayer:GetBackpack()`</td><td> Get the invisible player backpack. This is will return the backpack even if it has been disabled with a `info_hlvr_equip_player`. </td></tr><tr><td>

`RegisterPlayerEventCallback(event, callback, context)`</td><td>Register a callback function with for a player event.</td></tr><tr><td>

`UnregisterPlayerEventCallback(eventID)`</td><td>Unregisters a callback with a name.</td></tr><tr><td>

`CPropVRHand:MergeProp(prop, hide_hand)`</td><td>Merge an existing prop with this hand.</td></tr><tr><td>

`CPropVRHand:IsHoldingItem()`</td><td>Return true if this hand is currently holding a prop.</td></tr><tr><td>

`CPropVRHand:Drop()`</td><td>Drop the item held by this hand.</td></tr><tr><td>

`CPropVRHand:GetGlove()`</td><td>Get the rendered glove entity for this hand, i.e. the first `hlvr_prop_renderable_glove` class.</td></tr><tr><td>

`CPropVRHand:GetGrabbityGlove()`</td><td>Get the entity for this hands grabbity glove (the animated part on the glove).</td></tr><tr><td>

`CPropVRHand:IsButtonPressed(digitalAction)`</td><td>Returns true if the digital action is on for this. See `ENUM_DIGITAL_INPUT_ACTIONS` for action index values. Note: Only reports input when headset is awake. Will still transmit input when controller loses tracking.</td></tr><tr><td>

`CBaseEntity:Drop(self)`</td><td>Forces the player to drop this entity if held.</td></tr><tr><td>

`CBaseEntity:Grab(hand)`</td><td>Force the player to grab this entity with a hand. If no hand is supplied then the nearest hand will be used.</td></tr></table>



---

# storage.lua

> v3.2.0

Helps with saving/loading values for persistency between game sessions. Data is saved on a specific entity and if the entity is killed the values cannot be retrieved during that game session. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "storage"
```


### Usage 


Functions are accessed through the global 'Storage' table. When using dot notation (Storage.SaveNumber) you must provide the entity handle to save on. When using colon notation (Storage:SaveNumber) the script will find the best handle to save on (usually the player). 

Examples of storing and retrieving the following local values that might be defined at the top of the file: 



```lua
-- Getting the values to save
local origin = thisEntity:GetOrigin()
local hp     = thisEntity:GetHealth()
local name   = thisEntity:GetName()

-- Saving the values:

Storage:SaveVector("origin", origin)
Storage:SaveNumber("hp", hp)
Storage:SaveString("name", name)

-- Loading the values:

origin = Storage:LoadVector("origin")
hp     = Storage:LoadNumber("hp")
name   = Storage:LoadString("name")
```


This script also provides functions Storage.Save/Storage.Load for general purpose type inference storage. It is still recommended that you use the explicit type functions to keep code easily understandable, but it can help with prototyping: 



```lua
Storage:Save("origin", origin)
Storage:Save("hp", hp)
Storage:Save("name", name)

origin = Storage:Load("origin", origin)
hp     = Storage:Load("hp", hp)
name   = Storage:Load("name", name)
```


Entity versions of the functions exist to make saving to a specific entity easier: 



```lua
thisEntity:SaveNumber("hp", thisEntity:GetHealth())
thisEntity:SetHealth(thisEntity:LoadNumber("hp"))
```


### Complex Tables 


Since Lua allows tables to have keys and values to be virtually any value, `Storage.SaveTable` attempts to save and restore both using their native Storage functions, and does so recursively meaning nested tables can be saved. 

An example of safely restoring a class instance (assuming the class has a `new` method) where an instance is created and then the saved values are restored and added to the instance: 



```lua
vlua.tableadd(MyClass:new(), thisEntity:LoadTable("MyClass", {}))
```


Alternatively if the class uses a metatable and you have access to it: 



```lua
setmetatable(thisEntity:LoadTable("MyClass", {}), MyClass)
```


Functions for both key and value are currently not supported and will fail to save but will not block the rest of the table from being saved. This means you can save whole class tables and restore them with only the relevant saved data. 

### Delegate Save Functions 


Tables can utilize __save/__load functions to handle their specific saving needs. The table with these functions needs to be registered with the Storage module and any instances must have an `__index` key pointing to the base table: 



```lua
MyClass.__index = MyClass
Storage.RegisterType("MyClass", MyClass)
```


The functions may handle the data saving however they want but should generally use the base Storage functions to keep things safe and consistent. The below template functions may be copied to your script as a starting point. See `data/stack.lua` for an example of these functions in action. 



```lua
---@param handle EntityHandle # The entity to save on.
---@param name string # The name to save as.
---@param object MyClass # The object to save.
---@return boolean # If the save was successful.
function MyClass.__save(handle, name, object)
    return Storage.SaveTableCustom(handle, name, object, "MyClass")
end

---@param handle EntityHandle # Entity to load from.
---@param name string # Name to load.
---@return MyClass|nil # The loaded value. nil on fail.
function MyClass.__load(handle, name)
    local object = Storage.LoadTableCustom(handle, name, "MyClass")
    if object == nil then return nil end
    return setmetatable(object, MyClass)
end
```


Storage.Save and Storage.Load will now invoke these functions when appropriate. 

### Notes 


Strings longer than 62 characters are split up into multiple saves to work around the 64 character limit. This is handled automatically but should be taken into consideration when saving long strings. This limit does not apply to names. 

## Functions

<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`Storage.RegisterType(name, T)`</td><td> Register a class table type with a name. </td></tr><tr><td>

`Storage.UnregisterType(name, T)`</td><td> Unregister a class type. </td></tr><tr><td>

`Storage.Join(...)`</td><td> Join a list of values by the hidden separator. </td></tr><tr><td>

`Storage.SaveType(handle, name, T)`</td><td> Helper function for saving the type correctly. No failsafes are provided in this function, you must be sure you are saving correctly. </td></tr><tr><td>

`Storage.SaveString(handle, name, value)`</td><td> Save a string. </td></tr><tr><td>

`Storage.SaveNumber(handle, name, value)`</td><td> Save a number. </td></tr><tr><td>

`Storage.SaveBoolean(handle, name, bool)`</td><td> Save a boolean. </td></tr><tr><td>

`Storage.SaveVector(handle, name, vector)`</td><td> Save a Vector. </td></tr><tr><td>

`Storage.SaveQAngle(handle, name, qangle)`</td><td> Save a QAngle. </td></tr><tr><td>

`Storage.SaveTableCustom(handle, name, tbl, T, save_meta)`</td><td> Save a table with a custom type. Should be used with custom save functions.  If trying to save a normal table use `Storage.SaveTable`. </td></tr><tr><td>

`Storage.SaveTable(handle, name, tbl)`</td><td> Save a table.  May be ordered, unordered or mixed.  May have nested tables. </td></tr><tr><td>

`Storage.SaveEntity(handle, name, entity, useClassname)`</td><td> Save an entity reference.  Entity handles change between game sessions so this function modifies the passed entity to make sure it can keep track of it. </td></tr><tr><td>

`Storage.Save(handle, name, value)`</td><td> Save a value.  Uses type inference to save the value. If you are experiencing errors consider saving with one of the explicit type saves. </td></tr><tr><td>

`Storage.LoadString(handle, name, default)`</td><td> Load a string. </td></tr><tr><td>

`Storage.LoadNumber(handle, name, default)`</td><td> Load a number. </td></tr><tr><td>

`Storage.LoadBoolean(handle, name, default)`</td><td> Load a boolean value. </td></tr><tr><td>

`Storage.LoadVector(handle, name, default)`</td><td> Load a Vector. </td></tr><tr><td>

`Storage.LoadQAngle(handle, name, default)`</td><td> Load a QAngle. </td></tr><tr><td>

`Storage.LoadTableCustom(handle, name, T, default)`</td><td> Load a table with a custom type. Should be used with custom load functions.  If trying to load a normal table use `Storage.LoadTable`. </td></tr><tr><td>

`Storage.LoadTable(handle, name, default)`</td><td> Load a table with a custom type. </td></tr><tr><td>

`Storage.LoadEntity(handle, name, default)`</td><td> Load an entity. </td></tr><tr><td>

`Storage.Load(handle, name, default)`</td><td> Load a value. </td></tr><tr><td>

`Storage.LoadAll(handle, direct)`</td><td>Load all values saved to an entity.</td></tr></table>



