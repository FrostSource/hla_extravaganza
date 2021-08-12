# Common Properties

> These are properties that exist on all or most entities and therefore aren't mentioned in the individual entity guides.

|| Property | Raw | Description |
| -: | - | - | - |
| ⊟ | **Transform**
| ├ | origin | `origin` | The absolute position of this entity in the world.
| ├ | angles | `angles` | The orientation of this entity in the world.
| ├ | scales | `scales` | The scale of this entity's model.
| ├ | Transform Locked || Locks this entity at its current position, orientation and scale.
| ├ | Force Hidden || Hides this entity and stops it from compiling with the map.
| └ | Editor Only || This entity will only exist inside the editor and will not compile with the map.
|| Name | `targetname` | The name used to refer to this entity. Does not need to be unique and may contain any character including spaces.
| ⊟ | **Misc**
| └ | Entity Scripts | `vscripts` | Name(s) of script files that are executed after all entities have spawned. One or more space should be separate each script. ![With extension](img_vscripts_01.png) The `.lua` extension may be omitted from the filename. ![Without extension](img_vscripts_02.png)
| ⊟ | **Hierarchy**
| ├ | Parent | `parentname` | The name of this entity's parent in the movement hierarchy. Entities with parents move with their parent.<br>Special names:<br><br>`!player` - Parents the entity to the player entity if it exists.<br>`hmd_avatar` - Parents the entity to the player's head if in VR mode.
| ├ | Parent Model Bone / Attachment Name | `parentAttachmentName` | The name of the bone or attachment to attach to on the entity's parent in the movement hierarchy. Use !bonemerge to use bone-merge style attachment.
| ├ | Model Attachment position offset | `local.origin` | Offset in the local space of the parent model's attachment/bone to use in hierarchy. Not used if you are not using parent attachment.
| ├ | Model Attachment angular offset | `local.angles` | Angular offset in the local space of the parent model's attachment/bone to use in hierarchy. Not used if you are not using parent attachment.
| ├ | Model Attachment scale | `local.scales` | Scale in the local space of the parent model's attachment/bone to use in hierarchy. Not used if you are not using parent attachment.
| └ | Use Model Attachment Offset | `useLocalOffset` | Whether to respect the specified local offset when doing the initial hierarchical attachment to its parent.

## I/O
|| Name | Description |
| -: | - | - |
| **Inputs**
|| RunScriptFile | Load and execute a script file in this entity's script scope.
|| RunScriptCode | Execute a fragment of script code in this entity's script scope. Be aware that double quotes used to corrupt .vmf files. Corruption has not been noticed in .vmap files but single quotes can be used instead if you are worried.
|| CallScriptFunction | Call a script in this entity's script scope. Local functions can not be called.
|| CallPrivateScriptFunction | Calls a script function from this entity's private script scope.
|| CallGlobalScriptFunction | Calls a script function in the global script scope.
|| Kill | Removes this entity from the world. This is not the same as setting an entity's HP to 0.
|| KillHierarchy | Removes this entity and all of its children from the world.
|| AddOutput | Adds an entity I/O connection to this entity. Parameter format:<br>outputname>targetname>inputname>parameter>delay>max times to fire (-1 == infinite). Very dangerous, use with care.<br>Example:<br>OnPlayerPickup>!player>Cough>>0>1
|| FireUser1 | Causes this entity's OnUser1 output to be fired.
|| FireUser2 | Causes this entity's OnUser2 output to be fired.
|| FireUser3 | Causes this entity's OnUser3 output to be fired.
|| FireUser4 | Causes this entity's OnUser4 output to be fired.
| **Outputs**
|| OnUser1 | Fired in response to FireUser1 input.
|| OnUser2 | Fired in response to FireUser2 input.
|| OnUser3 | Fired in response to FireUser3 input.
|| OnUser4 | Fired in response to FireUser4 input.
|| OnKilled | Fired when the entity is killed and removed from the game.