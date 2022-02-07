# Grenade Zombie
by FrostSource

> ### A zombie that starts holding a frag or xen grenade who will throw it at the player, similar to the zombines seen in HL2 Episode 1.

---

## Assets required

- maps\prefabs\npc\grenade_zombie\grenade_zombie.vmap

---

## Properties

| Property | Description |
| - | - |
| Grenade Fuze Time | Amount of seconds before the grenade will explode once activated.
| Zombie Type | Type of zombie model to use.
| Activate Grenade On | Tells the prefab when to activate the grenade.<br>`Thrown` - As soon as the grenade is thrown at the player.<br>`Seen` - As soon as the zombie sees the player.<br>`Never` - The grenade will never be activated by the zombie.
| Grenade Type | The type of grenade the zombie will hold, `Frag` or `Xen`.

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| ForceSpawn | Spawns the zombie with the grenade.
| **Outputs**
|| OnGrenadeThrown | Fires when the grenade has been thrown at the player, regardless of activation.
|| OnGrenadeActivated | Fires when the grenade has been activated by the chosen method.

---