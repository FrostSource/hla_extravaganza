# Prefab name
by FrostSource

> ### Allows you to place a laser particle in the world or attached to and entity. The laser traces a given distance in the direction it's facing until it hits something.

---

## Assets required

- maps\prefabs\effects\traced_laser\traced_laser.vmap
- scripts\vscripts\prefabs\effects\traced_laser.lua

---

## Properties

| Property | Description |
| - | - |
| Color | RGB color for the particle. Not all particles can change color.
| Max Trace Distance | The maximum distance the laser is allowed to trace. Very large numbers can cause performance problems. You generally want 1024-2048 for lasers that move in large areas.
| Ignored Entity Name (use @) | The targetname of the entity the laser should ignore when tracing. If you place the laser inside the body of its parent to you should use the name of the parent.<br>You should use @ as the targetname prefix if you're not collapsing this prefab or disabling `Fixup entity names`.
| Parent (use @) | The targetname of the laser's parent in the movement hierarchy. Entities with parents move with their parent.<br>You should use @ as the targetname prefix if you're not collapsing this prefab or disabling `Fixup entity names`.
| Parent Model Attachment Name | The name of the bone or attachment to attach to on the entity's parent in the movement hierarchy.
| Model Attachment position offset | Offset in the local space of the parent model's attachment/bone to use in hierarchy. Not used if you are not using parent attachment.
| Model Attachment angular offset | Angular offset in the local space of the parent model's attachment/bone to use in hierarchy. Not used if you are not using parent attachment.
| Use Model Attachment Offset | Whether to respect the specified local offset when doing the initial hierarchical attachment to its parent.
| Start Active | Laser will start on and tracing.
| Laser Type | Type of particle to use for this laser:<br>`Pistol Laser`<br>`Shotgun Laser`<br>`Combine Console Laser`<br>`Scanner Laser`

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| Enable | Turns the laser on and starts tracing.
|| Disable | Turns the laser off and stops tracing.
|| Kill | Kills all entities in the prefab.
|| RunScriptCode | Execute a fragment of script code. Can be used to execute useful functions, e.g.<br>SetColor(r,g,b)
| **Outputs**

---