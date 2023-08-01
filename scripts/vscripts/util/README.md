> Last Updated 2023-08-01

## Index
1. [common.lua](#commonlua)
2. [enums.lua](#enumslua)
3. [globals.lua](#globalslua)

---

# common.lua

> v2.2.0

This file contains utility functions to help reduce repetitive code and add general miscellaneous functionality. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "util.util"
```


## Functions

<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`Util.GetHandIdFromTip(vr_tip_attachment)`</td><td> Convert vr_tip_attachment from a game event [1,2] into a hand id [0,1] taking into account left handedness. </td></tr><tr><td>

`Util.EstimateNearestEntity(name, class, position, radius)`</td><td> Estimates the nearest entity `position` with the targetname of `name` (or classname `class` if the name is blank). </td></tr><tr><td>

`Util.FindKeyFromValue(tbl, value)`</td><td> Attempt to find a key in `tbl` pointing to `value`. </td></tr><tr><td>

`Util.FindKeyFromValueDeep(tbl, value)`</td><td> Attempt to find a key in `tbl` pointing to `value` by recursively searching nested tables. </td></tr><tr><td>

`Util.TableSize(tbl)`</td><td>Returns the size of any table.</td></tr><tr><td>

`Util.RemoveFromTable(tbl, value)`</td><td> Remove a value from a table, returning it if it exists. </td></tr><tr><td>

`Util.AppendArray(array1, array2)`</td><td> Appends `array2` onto `array1` as a new array. Safe extend function alternative to `vlua.extend`. </td></tr><tr><td>

`Util.AppendArrays(array, ...)`</td><td>Append any number of arrays onto `array` and return as a new array. Safe extend function alternative to `vlua.extend`.</td></tr><tr><td>

`Util.Delay(func, delay)`</td><td> Delay some code. </td></tr><tr><td>

`Util.QAngleFromVector(vec)`</td><td> Get a new `QAngle` from a `Vector`. This simply transfers the raw values from one to the other. </td></tr><tr><td>

`Util.CreateConstraint(entity1, entity2, class, properties)`</td><td>Create a constraint between two entity handles.</td></tr><tr><td>

`Util.Choose(...)`</td><td>Choose and return a random argument.</td></tr><tr><td>

`Util.VectorFromString(str)`</td><td>Turns a string of up to three numbers into a vector.</td></tr></table>



---

# enums.lua

> v



## Functions

<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr></table>



---

# globals.lua

> v1.0.0

Provides common global functions used throughout extravaganza libraries. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "util.globals"
```


## Functions

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

`devprint(...)`</td><td> Prints all arguments if convar "developer" is greater than 0. </td></tr><tr><td>

`devprints(...)`</td><td> Prints all arguments on a new line instead of tabs if convar "developer" is greater than 0. </td></tr><tr><td>

`devprintn(...)`</td><td> Prints all arguments with spaces between instead of tabs if convar "developer" is greater than 0. </td></tr><tr><td>

`devprint2(...)`</td><td> Prints all arguments if convar "developer" is greater than 1. </td></tr><tr><td>

`devprints2(...)`</td><td> Prints all arguments on a new line instead of tabs if convar "developer" is greater than 1. </td></tr><tr><td>

`devprintn2(...)`</td><td> Prints all arguments with spaces between instead of tabs if convar "developer" is greater than 1. </td></tr><tr><td>

`Expose(func, name, scope)`</td><td> Add a function to the calling entity's script scope with alternate casing.  Makes a function easier to call from Hammer through I/O.  E.g.      local function TriggerRelay(io)         DoEntFire("my_relay", "Trigger", "", 0, io.activator, io.caller)     end     Expose(TriggerRelay)     -- Or with alternate name     Expose(TriggerRelay, "RelayInput") </td></tr><tr><td>

`IsVector(value)`</td><td> Get if a value is a `Vector` </td></tr><tr><td>

`IsQAngle(value)`</td><td> Get if a value is a `QAngle` </td></tr><tr><td>

`DeepCopyTable(tbl)`</td><td> Copy all keys from `tbl` and any nested tables into a brand new table and return it. This is a good way to get a unique reference with matching data.  Any functions and userdata will be copied by reference, except for: `Vector`, `QAngle` </td></tr><tr><td>

`RandomFromArray(array, min, max)`</td><td> Returns a random value from an array. </td></tr><tr><td>

`RandomFromTable(tbl)`</td><td> Returns a random key/value pair from a unordered table. </td></tr><tr><td>

`ShuffleArray(t)`</td><td> Shuffles a given array.  </td></tr><tr><td>

`TraceLineExt(parameters)`</td><td> Does a raytrace along a line with extended parameters. You ignore multiple entities as well as classes and names. Because the trace has to be redone multiple times, a `timeout` parameter can be defined to cap the number of traces. </td></tr><tr><td>

`TraceLineWorld(parameters)`</td><td> Does a raytrace along a line until it hits or the world or reaches the end of the line. </td></tr><tr><td>

`IsWorld(entity)`</td><td> Get if an entity is the world entity. </td></tr><tr><td>

`GetWorld()`</td><td> Get the world entity. </td></tr><tr><td>

`truthy(value)`</td><td> Check if a value is truthy or falsy. </td></tr></table>



