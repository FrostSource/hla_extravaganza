> Last Updated 2022-11-07

---

# core.lua (v1.0.1)

The core math extension script. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "math.core"
```


<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`math.sign(x)`</td><td> Get the sign of a number. </td></tr></table>



---

# weighted_random.lua (v1.2.2)

Weighted random allows you to assign chances to tables. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "math.weighted_random"
```


### Usage 


The WeightedRandom() function takes a list of tables where each one must at least contain a key with the name "weight" pointing to a number value. The table may contain any other keys/values you wish and will be returned if this weight is chosen. 

Weights do not need to be [0-1] range. 



```lua
local wr = WeightedRandom({
    { weight = 1, name = "Common" },
    { weight = 0.75, name = "Semi-common" },
    { weight = 0.5, name = "Uncommon" },
    { weight = 0.25, name = "Rare" },
    { weight = 0.1, name = "Extremely rare" },
})

for i = 1, 20 do
    print(wr:Random().name)
end
```


<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`WR:TotalWeight(tbl, weight)`</td><td> Add a table value with an associated weight. If `tbl` already has a weight key then `weight` parameter can be omitted.  Note: The table `tbl` is not cloned, the given reference is used.   Get the total weight of this weighted random object. </td></tr><tr><td>

`WR:Random()`</td><td> Pick a random table from the list of weighted tables. </td></tr><tr><td>

`WeightedRandom(weights)`</td><td> Create a new WeightedRandom object with given weights.  E.g.      local wr = WeightedRandom({         { weight = 1, name = "Common" },         { weight = 0.75, name = "Semi-common" },         { weight = 0.5, name = "Uncommon" },         { weight = 0.25, name = "Rare" },         { weight = 0.1, name = "Extremely rare" },     })  Params: </td></tr></table>



