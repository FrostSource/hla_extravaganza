# Attached Instructor Hint
by FrostSource

> ### An instructor hint which can be attached to hand, hmd, or entity.

---

## Assets required

- maps\prefabs\gameplay\attached_instructor_hint\attached_instructor_hint.vmap

---

## Properties

| Property | Description |
| - | - |
| Hint Offset | The offset from the attached object. Can look strange with entity attachment.
| Target Entity | Specify targetname of the entity to attach to if `Entity` was chosen in `Panel Attach Type`.
| Caption | The text of your hint.
| Start Sound | Sound to play when the lesson starts.
| Timeout | The automatic timeout for the hint in seconds. 0 will persist until stopped with EndHint.
| Layout Type | Panorama Layout file to be used. Custom requires specifying .xml file.
| Custom Layout File | Custom Path to a xml file ie - file://{resources}/layout/custom_hint.xml
| Height Offset | Height offset from the target entities root the panel should be displayed at. Unfortunately does not seem to have any effect.
| Panel Attach Type | Attach Type for the Panorama Panel.<br><br>Dominant Hand: Attaches to the hand set as primary.<br>Off Hand: Attaches to the opposite hand set as primary.<br>HMD: Attaches to the player's head in front of their eyes.<br>Entity: Attaches to the origin point of an entity.

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| ShowHint | Start showing the hint.
|| EndHint | Stop showing the hint if it hasn't already timed out.
|| Kill | Removes this entity from the world.

---