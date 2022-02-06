# util <!-- omit in toc -->

> Utility scripts and libraries for extending base functionality of Alyx. These are typically loaded into the global scope and will explicitly mention if loaded another way. If a library is dependant on another library it will be stated at the very bottom of the file's header comment, for example in `player.lua`:

```lua
require "util.util"
require "util.storage"
```

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

```lua
require "util.util
```

This is the main utility script and is often used by other libraries.
| Function | Signature | Description |
| -------- | --------- | ----------- |
| GetScriptFile | `lua GetScriptFile(sep?: string)->string`       | |
| Paragraph   | Text        | |

<table>
<tr>
<td>Function</td><td>Signature</td>
</tr>

<tr>
<td>GetScriptFile</td>
<td>
```lua
GetScriptFile(sep?: string)->string
```
</td>
</tr>

</table>

### storage.lua

### debug.lua

### enums.lua

## Class Extensions

### player.lua

## Data Type Libraries

### weighted_random.lua

### stack.lua

### queue.lua

### inventory.lua

