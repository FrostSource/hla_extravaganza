> Last Updated 2022-11-07

---

# enums.lua (v)



<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr></table>



---

# util.lua (v2.0.1)

This file contains utility functions to help reduce repetitive code and add general miscellaneous functionality. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "util.util"
```


<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`Util.GetHandIdFromTip(vr_tip_attachment)`</td><td> Convert vr_tip_attachment from a game event [1,2] into a hand id [0,1] taking into account left handedness. </td></tr><tr><td>

`Util.EstimateNearestEntity(name, class, position, radius)`</td><td> Estimates the nearest entity `position` with the targetname of `name` (or classname `class` if the name is blank). </td></tr><tr><td>

`Util.FindKeyFromValue(tbl, value)`</td><td> Attempt to find a key in `tbl` pointing to `value`. </td></tr><tr><td>

`Util.FindKeyFromValueDeep(tbl, value)`</td><td> Attempt to find a key in `tbl` pointing to `value` by recursively searching nested tables. </td></tr><tr><td>

`Util.TableSize(tbl)`</td><td>Returns the size of any table.</td></tr><tr><td>

`Util.RemoveFromTable(tbl, value)`</td><td> Remove a value from a table, returning it if it exists. </td></tr><tr><td>

`Util.AppendArray(array1, array2)`</td><td> Appends `array2` onto `array1` as a new array. Safe extend function alternative to `vlua.extend`. </td></tr><tr><td>

`Util.Delay(func, delay)`</td><td> Delay some code. </td></tr></table>



