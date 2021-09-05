# Undocumented player inputs

> The player entity has undocumented inputs that are used throughout the base game. This is a list the currently known inputs and how they work.

## I/O
|| Name | Description |
| -: | - | - |
| **Inputs**
|| ApplyContinuousHapticPulse | Could not get this input to work.
|| Cough | Makes the player cough for a few seconds. Can be triggered periodically to keep the player coughing.
|| EnableTeleport | Enables teleport and continuous movement. Parameter override of 1 to enable and 0 to disable.
|| ForceDropPhysObjects | Forces the player to drop any held objects.
|| GiveVortEnergy | Gives player vort energy weapon immediately. Can remove with StopVortEnergyOverload.
|| GiveVortEnergyHint | Vibrates both hands with vort energy particles for a few seconds. Will stack and glow brighter.
|| GiveVortEnergyResidual | Gives player hands a small vort energy particle effect.
|| GiveVortEnergyOverload | Gives player hands large vort energy particle and sound effect.
|| PerformFakeExplosiveDeath | Destroys any of the 3 explosive prop_physics which are less than 512 units and kills the player. If no explosives exist in range the player will not die.
|| SetAnchorParent | Sets the HMD anchor parent to the entity with the passed targetname.
|| SetDamageFilter | Sets the player's damage filter to the filter with the passed targetname. Pass an empty value to reset it.
|| SetGrabbityGlovePowerLevel | Setting to 0 disables gravity glove pull. Setting greater than 1 will return a small amount of power. This seems to reset on map change.
|| SetHealth | Sets player health to passed value. Passing 0 or nothing will kill the player.
|| ShockForTime | Applies a shock particle to hands for number of seconds, no sound or damage.
|| StopVortEnergyResidual | Stops the residual energy effect on player hands.
|| StopVortEnergyOverload | Stops the overload energy effect on player hands. Can choose individual hands by passing 'left' or 'right'.
|| SuppressCough | Stops the player from coughing. Enable with 1, disable with 0.