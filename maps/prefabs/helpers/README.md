# Editor Helpers
by FrostSource

> ### Combines all standard helper prefabs into one prefab.

> All helper prefabs are required for this prefab to work.

---

## Assets required

- maps\prefabs\helpers\editor_helpers.vmap
- maps\prefabs\helpers\debug_basics\debug_basics.vmap
- maps\prefabs\helpers\player_editor_inputs\player_editor_inputs.vmap

---

## Properties

| Property | Description |
| - | - |
| God | Player starts invincible.
| No Clip | In nonvr this is a standard `noclip` command. In vr `hlvr_toggle_dev_teleport` is called.
| View Manhack Nav | Turns on `ai_show_connect_fly` and activates the `tiny_centered` hull.
| Give Weapons | In nonvr the smg1 is given. In vr an equip gives all vr weapons/items.
| Restart On Death | Restarts the map when the player dies.

---

## Input / Output

See [undocumented !player inputs](../../../guides/entities/undocumented_player_inputs.md).

---

## Images

![Example image](example_image.jpg)