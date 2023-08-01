> Last Updated 2023-08-01

## Index
1. [common.lua](#commonlua)

---

# common.lua

> v1.6.0

Debug utility functions. 

If not using `vscripts/core.lua`, load this file at game start using the following line: 



```lua
require "debug.core"
```


## Functions

<table><tr><td><b>Function</b></td><td><b>Description</b></td></tr><tr><td>

`Debug.PrintEntityList(list)`</td><td> Prints useful entity information about a list of entities, such as classname and model. </td></tr><tr><td>

`Debug.PrintAllEntities()`</td><td> Prints information about all existing entities. </td></tr><tr><td>

`Debug.PrintEntities(search, exact, dont_include_parents)`</td><td> Print entities matching a search string.  Searches name, classname and model name. </td></tr><tr><td>

`Debug.PrintAllEntitiesInSphere()`</td><td>Prints information about all entities within a sphere.</td></tr><tr><td>

`Debug.PrintTable(tbl, prefix, ignore, meta)`</td><td> Prints the keys/values of a table and any tested tables.  This is different from `DeepPrintTable` in that it will not print members of entity handles. </td></tr><tr><td>

`Debug.PrintTableShallow(tbl)`</td><td> Prints the keys/values of a table but not any tested tables. </td></tr><tr><td>

`Debug.PrintList()`</td><td></td></tr><tr><td>

`Debug.FindEntity(ent, duration)`</td><td> Draws a debug line to an entity in game. </td></tr><tr><td>

`Debug.PrintEntityCriteria(ent)`</td><td> Prints all current context criteria for an entity. </td></tr><tr><td>

`Debug.PrintEntityBaseCriteria(ent)`</td><td> Prints current context criteria for an entity except for values saved using `storage.lua`. </td></tr><tr><td>

`Debug.GetClassname()`</td><td></td></tr><tr><td>

`Debug.PrintGraph(height, min_val, max_val, name_value_pairs)`</td><td> Prints a visual ASCII graph showing the distribution of values between a min/max bound.  E.g.      Debug.PrintGraph(6, 0, 1, {         val1 = RandomFloat(0, 1),         val2 = RandomFloat(0, 1),         val3 = RandomFloat(0, 1)     })     ->     1^ []              | []    []        | [] [] []        | [] [] []        | [] [] []       0 ---------->        v  v  v           a  a  a           l  l  l           3  1  2        val3 = 0.96067351102829     val1 = 0.5374761223793     val2 = 0.7315416932106 </td></tr><tr><td>

`Debug.PrintInheritance(ent)`</td><td> Prints a nested list of entity inheritance. </td></tr><tr><td>

`Debug.SimpleVector(vector)`</td><td>Returns a simplified vector string with decimal places truncated.</td></tr></table>



