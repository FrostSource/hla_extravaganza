> Last Updated 2023-06-04

---

# core.lua (v1.3.0)

The main core script provides useful global functions as well as loading any standard libraries that it can find. 

The two main purposes are: 

1. Automatically load libraries to simplify the process for users.
2. Provide entity class functions to emulate OOP programming.


Load this script into the global scope using the following line: 



```lua
require "core"
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


<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`GetScriptFile(sep, level)`</td><td> Get the file name of the current script without folders or extension. E.g. `util.util` </td></tr><tr><td>

`IsEntity(handle, checkValidity)`</td><td> Get if the given `handle` value is an entity, regardless of if it's still alive.  A common usage is replacing the often used entity check:      if entity ~= nil and IsValidEntity(entity) then  With:      if IsEntity(entity, true) then </td></tr><tr><td>

`AddOutput(handle, output, target, input, parameter, delay, activator, caller, fireOnce)`</td><td> Add an output to a given entity `handle`. </td></tr><tr><td>

`module_exists(name)`</td><td> Checks if the module/script exists. </td></tr><tr><td>

`ifrequire(modname, callback)`</td><td> Loads the given module, returns any value returned by the given module(`true` when module returns nothing).  Then runs the given callback function.  If the module fails to load then the callback is not executed and no error is thrown. </td></tr><tr><td>

`IncludeScript(scriptFileName, scope)`</td><td> Execute a script file. Included in the current scope by default. </td></tr><tr><td>

`IsVREnabled()`</td><td> Gets if the game was started in VR mode. </td></tr><tr><td>

`prints(...)`</td><td> Prints all arguments with spaces between instead of tabs. </td></tr><tr><td>

`printn(...)`</td><td> Prints all arguments on a new line instead of tabs. </td></tr><tr><td>

`Expose(func, name, scope)`</td><td> Add a function to the calling entity's script scope with alternate casing.  Makes a function easier to call from Hammer through I/O.  E.g.      local function TriggerRelay(io)         DoEntFire("my_relay", "Trigger", "", 0, io.activator, io.caller)     end     Expose(TriggerRelay)     -- Or with alternate name     Expose(TriggerRelay, "RelayInput") </td></tr><tr><td>

`IsVector(value)`</td><td> Get if a value is a `Vector` </td></tr><tr><td>

`IsQAngle(value)`</td><td> Get if a value is a `QAngle` </td></tr><tr><td>

`DeepCopyTable(tbl)`</td><td> Copy all keys from `tbl` and any nested tables into a brand new table and return it. This is a good way to get a unique reference with matching data.  Any functions and userdata will be copied by reference, except for: `Vector`, `QAngle` </td></tr><tr><td>

`RandomFromArray(array, min, max)`</td><td> Returns a random value from an array. </td></tr><tr><td>

`TraceLineExt(parameters)`</td><td> Does a raytrace along a line with extended parameters. You ignore multiple entities as well as classes and names. Because the trace has to be redone multiple times, a `timeout` parameter can be defined to cap the number of traces. </td></tr><tr><td>

`IsWorld(entity)`</td><td> Get if an entity is the world entity. </td></tr><tr><td>

`GetWorld()`</td><td> Get the world entity. </td></tr><tr><td>

`haskey()`</td><td></td></tr><tr><td>

`EntityClassBase:Set(name, value)`</td><td>Assign to new value to entity's member `name`. This also saves the member.</td></tr><tr><td>

`self:Set()`</td><td></td></tr><tr><td>

`inherit(script)`</td><td>Inherit an existing entity class which was defined using `entity` function.</td></tr><tr><td>

`entity(name, ...)`</td><td> Creates a new entity class.  If this is called in an entity attached script then the entity automatically inherits the class and the class inherits the entity's metatable.  The class is only created once so this can be called in entity attached scripts multiple times and all subsequent calls will return the already created class. </td></tr><tr><td>

`getinherits()`</td><td></td></tr><tr><td>

`printmeta()`</td><td></td></tr></table>



---

# gesture.lua (v1.0.1)

Provides a system for tracking simple hand poses and gestures. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "gesture"
```


### Usage 


Gestures are added with a unique name and a [0-1] curl range for each finger, or nil if the finger shouldn't be taken into consideration. 



```lua
Gesture:AddGesture("AllFingersNoThumb", 1, 1, 1, 1, 0)
```


Built-in gestures can be removed to lower a small amount of processing cost, however this might produce undesirable results for other mods using the same gesture script if you plan to use a system like Scalable Init. 



```lua
Gesture:RemoveGestures({"OpenHand", "ClosedFist"})
```


Recommended usage for tracking gestures is to register a callback function with a given set of conditions: 



```lua
Gesture:RegisterCallback("start", 1, "ThumbsUp", nil, function(gesture)
    ---@cast gesture GESTURE_CALLBACK
    print(("Player made %s gesture at %d"):format(gesture.name, gesture.time))
end)
```


Generic gesture functions exist for all other times: 



```lua
local g = Gesture:GetGesture(Player.PrimaryHand)
if g.name == "ThumbsUp" then
    print("Player did thumbs up")
end

local g = Gesture:GetGestureRaw(Player.PrimaryHand)
if g.index > 0.5 then
    print("Player has index more than half extended")
end
```


<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`Gesture:AddGesture(name, index, middle, ring, pinky, thumb)`</td><td> Add a new gesture to watch for.  If a finger position is nil then the finger isn't taken into consideration. </td></tr><tr><td>

`Gesture:RemoveGesture(name)`</td><td> Remove an existing gesture.  Any callbacks registered with the gesture will be unregistered. </td></tr><tr><td>

`Gesture:RemoveGestures(names)`</td><td> Remove a list of gestures. </td></tr><tr><td>

`Gesture:GetGesture(hand)`</td><td> Gets the current gesture name of a given hand.  E.g.       local g = Gesture:GetGesture(Player.PrimaryHand)      if g.name == "ThumbsUp" then          do_something()      end </td></tr><tr><td>

`Gesture:GetGestureRaw(hand)`</td><td> Gets the current [0-1] finger curl values of a given hand. </td></tr><tr><td>

`Gesture:RegisterCallback(kind, hand, gesture, duration, callback, context)`</td><td> Register a callback for a specific gesture start/stop. </td></tr><tr><td>

`Gesture:UnregisterCallback(callback)`</td><td> Unregister a callback function. </td></tr><tr><td>

`Gesture:Start(on)`</td><td> Starts the gesture system. </td></tr><tr><td>

`Gesture:Stop()`</td><td> Stops the gesture system. </td></tr></table>



---

# input.lua (v1.1.0)

Simplifies the tracking of button presses/releases. This system will automatically start when the player spawns unless told not to before the player spawns. 



```lua
Input.AutoStart = false
```


If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "input"
```


### Usage 


The system can be told to track all buttons or individual buttons for those who are performant conscious: 



```lua
Input:TrackAllButtons()
Input:TrackButtons({7, 17})
```


Common usage is to register a callback function which will fire whenever the passed conditions are met. `press`/`release` can be individually registered, followed by which hand to check (or -1 for both), the digital button to check, number of presses (if `press` kind), and the function to call. 



```lua
Input:RegisterCallback("press", 1, 7, 1, function(data)
    ---@cast data INPUT_PRESS_CALLBACK
    print(("Button %s pressed at %.2f on %s"):format(
        Input:GetButtonDescription(data.button),
        data.press_time,
        Input:GetHandName(data.hand)
    ))
end)
```




```lua
Input:RegisterCallback("release", -1, 17, nil, function(data)
    ---@cast data INPUT_RELEASE_CALLBACK
    if data.held_time >= 5 then
        print(("Button %s charged for %d seconds on %s"):format(
            Input:GetButtonDescription(data.button),
            data.held_time, 
            Input:GetHandName(data.hand)
        ))
    end
end)
```


Other general use functions exist for checking presses and are extended to the hand class for ease of use: 



```lua
if Player.PrimaryHand:Pressed(3) then end
if Player.PrimaryHand:Released(3) then end
if Player.PrimaryHand:Button(3) then end
if Player.PrimaryHand:ButtonTime(3) >= 5 then end
```


<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`Input:TrackButton(button)`</td><td> Set a button to be tracked. </td></tr><tr><td>

`Input:TrackButtons(buttons)`</td><td> Set an array of buttons to be tracked. </td></tr><tr><td>

`Input:StopTrackingAllButtons()`</td><td> Stop all buttons from being tracked. </td></tr><tr><td>

`Input:TrackAllButtons()`</td><td> Set all buttons to be tracked. </td></tr><tr><td>

`Input:StopTrackingButton(button)`</td><td> Stop tracking a button. </td></tr><tr><td>

`Input:StopTrackingButtons(buttons)`</td><td> Stop tracking an array of buttons. </td></tr><tr><td>

`Input:Pressed(hand, button, lock)`</td><td> Get if a button has just been pressed for a given hand. Optionally lock the button press so it can't be detected by other scripts until it is released. </td></tr><tr><td>

`Input:Released(hand, button, lock)`</td><td> Get if a button has just been released for a given hand. Optionally lock the button release so it can't be detected by other scripts until it is pressed. </td></tr><tr><td>

`Input:Button(hand, button)`</td><td> Get if a button is currently being held down for a given hand. </td></tr><tr><td>

`Input:ButtonTime(hand, button)`</td><td> Get the amount of seconds a button has been held for a given hand. </td></tr><tr><td>

`Input:GetButtonDescription(button)`</td><td> Get the description of a given button. Useful for debugging or hint display. </td></tr><tr><td>

`Input:GetHandName(hand, use_operant)`</td><td> Get the name of a hand. </td></tr><tr><td>

`Input:RegisterCallback(kind, hand, button, presses, callback)`</td><td> Register a callback for a specific button press/release.  | '"press"' # Button is pressed. | '"release"' # Button is released. | `-1` # Both hands. | `0`  # Left Hand. | `1`  # Right Hand. | `2`  # Primary Hand. | `3`  # Secondary Hand.</td></tr><tr><td>

`Input:UnregisterCallback(callback)`</td><td> Unregisters a specific callback from all buttons and hands. </td></tr><tr><td>

`CPropVRHand:Pressed(button, lock)`</td><td> Get if a button has just been pressed for this hand. Optionally lock the button press so it can't be detected by other scripts until it is released. </td></tr><tr><td>

`CPropVRHand:Released(button, lock)`</td><td> Get if a button has just been released for this hand. Optionally lock the button release so it can't be detected by other scripts until it is pressed. </td></tr><tr><td>

`CPropVRHand:Button(button)`</td><td> Get if a button is currently being held down for a this hand. </td></tr><tr><td>

`CPropVRHand:ButtonTime(button)`</td><td> Get the amount of seconds a button has been held for this hand. </td></tr><tr><td>

`Input:Start(on)`</td><td> Starts the input system. </td></tr><tr><td>

`Input:Stop()`</td><td> Stops the input system. </td></tr></table>



---

# player.lua (v2.2.0)

Player script allows for more advanced player manipulation and easier entity access for player related entities by extending the player class. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "player"
```


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

`RegisterPlayerEventCallback(event, callback, context)`</td><td>Register a callback function with for a player event.</td></tr><tr><td>

`UnregisterPlayerEventCallback(callback)`</td><td>Unregisters a callback with a name.</td></tr><tr><td>

`CPropVRHand:MergeProp(prop, hide_hand)`</td><td>Merge an existing prop with this hand.</td></tr><tr><td>

`CPropVRHand:IsHoldingItem()`</td><td>Return true if this hand is currently holding a prop.</td></tr><tr><td>

`CPropVRHand:Drop()`</td><td>Drop the item held by this hand.</td></tr><tr><td>

`CPropVRHand:GetGlove()`</td><td>Get the rendered glove entity for this hand.</td></tr><tr><td>

`CPropVRHand:GetGrabbityGlove()`</td><td>Get the entity for this hands grabbity glove (the animated part on the glove).</td></tr><tr><td>

`CPropVRHand:IsButtonPressed(digitalAction)`</td><td>Returns true if the digital action is on for this. See `ENUM_DIGITAL_INPUT_ACTIONS` for action index values. Note: Only reports input when headset is awake. Will still transmit input when controller loses tracking.</td></tr><tr><td>

`CBaseEntity:Drop(self)`</td><td>Forces the player to drop this entity if held.</td></tr><tr><td>

`CBaseEntity:Grab(hand)`</td><td>Force the player to grab this entity with a hand. If no hand is supplied then the nearest hand will be used.</td></tr></table>



---

# storage.lua (v2.4.1)

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

`Storage.SaveEntity(handle, name, entity)`</td><td> Save an entity reference.  Entity handles change between game sessions so this function modifies the passed entity to make sure it can keep track of it. </td></tr><tr><td>

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



