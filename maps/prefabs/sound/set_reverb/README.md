# Set Reverb
by FrostSource

> ### Artificially changes the amount of reverb applied to sounds.

> Be careful with high values (above 5), sounds can become very loud. [-6,3] are good values to play with.

---

## Assets required

- maps\prefabs\sound\set_reverb\set_reverb.vmap

---

## Properties

| Property | Description |
| - | - |
| Start Disabled | Prefab will not set any reverb value until it is enabled and told to change.
| Initial Reverb Value | The initial amount of reverb to be applied when spawned (unless `Start Disabled` is ticked).

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| Disable | Disallows the prefab from setting reverb mix level. This will not change the reverb level or set it back to normal.
|| Enable | Allows the prefab to set reverb mix level.
|| SetReverbValue | Sets the reverb mix level if enabled. Default is -6.
| **Outputs**
||  | 

---

## Notes

- Reverb will not be reapplied between game sessions if the prefab is disabled.
- If you want to turn high reverb on and off you should send an input of `SetReverbValue` both times, one for your high value and one for `-6` to set it back to default.