# Sound Param
by FrostSource

> ### A way to quickly get a snd_event_point with attached snd_event_param into a map.

---

## Assets required

- maps\prefabs\sound\sound_mod\sound_param.vmap

---

## Properties

| Property | Description |
| - | - |
| Parameter | Name of the parameter to set.
| Float Value | Initial value of the chosen `Paremeter`.
| Sound Event Name | Name of the sound event to play.
| Source Entity Name | Name of the entity the sound should emit from. Use @ to avoid name fix-up.
| Save & Restore | This soundevent should be saved and restored on load.
| Start On Spawn | Play the sound immediately upon spawning.
| Entity Attachment Name | If set, will play the soundevent from this attachment point.

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| SetFloatValue | Set the value of the soundevent parameter.
|| SetParamName | Set the name of the parameter to set on the soundevent.
|| StartSound | Start the sound event. If an entity name is provided, the sound will originate from that entity.
|| StopSound | Stop the sound event.
| **Outputs**
||

---

## Images

![Example image. Not required](example_image.jpg)