# info_player_start

https://developer.valvesoftware.com/wiki/Info_player_start

Indicates the position and facing direction at which the player will spawn. If there isn't at least one of this entity in the map the player will start at world position (0, 0, 0). If more than one exists then the info_player_start that was placed in the map first is chosen.

## Properties

|| Property | Raw | Description |
| -: | - | - | - |
|| Start Disabled | `StartDisabled` | This property appears to have to effect in single player.
| ⊟ | **spawnflags** | `spawnflags`
| ├ | Master (Has priority if multiple info_player_starts exist) | `1` | Marks the entity as being the priority spawn location even if it was placed after other info_player_start entities. This is useful for making one the map start location while keeping all others to use for testing in conjunctions with cordons.<br><br>If multiple have this spawnflag then the info_player_start that was placed in the map first with this spawnflag is chosen.
| └ | VR Anchor location (vs player location) | `2` | If ticked the player will spawn offset from this entity relative to their offset from the HMD anchor position. You can think of the anchor as the centre of the VR play-space, the position marked by the feet on the ground in menus.<br><br>Be careful, if the entity is close to a wall and the player is not centred in their play-space they may start inside the wall.
|

## I/O
|| Name | Description |
| -: | - | - |
| **Outputs**
|
| **Inputs**
|| Enable | Enable this entity. (Seems to have no effect in single player.)
|| Disable | Disable this entity. (Seems to have no effect in single player.)
|| Toggle | Toggle the enable/disable state of this player spawn position. (Seems to have no effect in single player.)

## Notes

This entity is not the same as the player entity. It exists only as location data. Killing this entity will not kill the player.

Scripts can be attached to this entity as well as think functions; it exists and is active during the life-time of the map (or until killed manually).

The entity can be rotated on any access and in Non-VR will cause the player to have a limited tilted view.

Scaling has no effect on player size.

