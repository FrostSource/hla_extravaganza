# Logic Player Extension
by FrostSource

> ### Provides more advanced interaction with the player entity.

> For example forcing the player to drop a specific item or from a specific hand.

---

## Assets required

- maps\prefabs\logic\logic_player_extension\logic_player_extension.vmap
- scripts\vscripts\prefabs\logic\logic_player_extension.lua
- scripts\vscripts\util\player.lua
- scripts\vscripts\util\util.lua

---

## Properties

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| DropActivator | Forces the player to drop the activator in the IO chain if any.
|| DropCaller | Forces the player to drop the caller in the IO chain if any.
|| DropLeftHand | Forces the player to drop the item in their left hand if any.
|| DropRightHand | Forces the player to drop the item in their right hand if any.
|| DropPrimaryHand | Forces the player to drop the item in their primary hand if any.
|| DropSecondaryHand | Forces the player to drop the item in their secondary hand if any.
|| GetHeldLeftHand | Fires OnGetHeldLeftHand with the item held by the player's left hand as the activator in the IO chain if any.
|| GetHeldRightHand | Fires OnGetHeldRightHand with the item held by the player's right hand as the activator in the IO chain if any.
|| GetHeldPrimaryHand | Fires OnGetHeldPrimaryHand with the item held by the player's primary hand as the activator in the IO chain if any.
|| GetHeldSecondaryHand | Fires OnGetHeldSecondaryHand with the item held by the player's primary hand as the secondary in the IO chain if any.
| **Outputs**
|| OnGetHeldLeftHand | Fired by GetHeldLeftHand.
|| OnGetHeldRightHand | Fired by GetHeldRightHand.
|| OnGetHeldPrimaryHand | Fired by GetHeldPrimaryHand.
|| OnGetHeldSecondaryHand | Fired by GetHeldSecondaryHand.

---