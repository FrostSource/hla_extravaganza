# Interactive Objects
by FrostSource

> ### A collection of prop_animinteractable entities with pre-defined sounds and properties. Each prefab has basic functionally to be used as-is or collapsed for easy extending without having to remember specific values.

---

## Assets required

- maps\prefabs\interactive_objects\citizen_switch_slide.vmap
- maps\prefabs\interactive_objects\combine_switch_arclever.vmap
- maps\prefabs\interactive_objects\combine_switch_pulltwist.vmap
- maps\prefabs\interactive_objects\combine_switch_pulltwist_alt.vmap
- maps\prefabs\interactive_objects\combine_switch_pulltwist_alt_lights.vmap
- maps\prefabs\interactive_objects\combine_switch_slide.vmap
- maps\prefabs\interactive_objects\frankenswitch.vmap
- maps\prefabs\interactive_objects\radioset_customizable.vmap
- maps\prefabs\interactive_objects\rollingdoor_large.vmap
- maps\prefabs\interactive_objects\rollingdoor.vmap
- maps\prefabs\interactive_objects\window_apartment.vmap

---
<br>

## **citizen_switch_slide**

> A simple vertical lever that the player must pull down.

## Properties

| Property | Description |
| - | - |
| Start Locked | Player will not be able to use this prop_animinteractable until it unlocked.
| Return to Completion | When the player releases the handle, returns autonomously to the starting position.
| Resistance | Amount of resistance on movement (i.e. 1.0 no resistance, 0.1 strong resistance).

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| Lock | Locks the interactable.
|| Unlock | Unlocks the interactable.
|| EnableReturnToCompletion | Interactable **will** autonomously return to starting position when let go.
|| DisableReturnToCompletion | Interactable **will *not*** autonomously return to starting position when let go.
| **Outputs**
|| OnSwitchUp | Player moved the switch to the up position.
|| OnSwitchDown | Player moved the switch to the down position.

---
<br>

## **combine_switch_arclever**

> A large arcing lever that the player must pull down.

## Properties

| Property | Description |
| - | - |
| Start Locked | Player will not be able to use this prop_animinteractable until it unlocked.
| Return to Completion | When the player releases the handle, returns autonomously to the starting position.
| Resistance | Amount of resistance on movement (i.e. 1.0 no resistance, 0.1 strong resistance).

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| Lock | Locks the interactable.
|| Unlock | Unlocks the interactable.
|| EnableReturnToCompletion | Interactable **will** autonomously return to starting position when let go.
|| DisableReturnToCompletion | Interactable **will *not*** autonomously return to starting position when let go.
| **Outputs**
|| OnSwitchUp | Player moved the switch to the up position.
|| OnSwitchDown | Player moved the switch to the down position.

---
<br>

## **combine_switch_pulltwist**

> Must be pulled out of a socket and turned clockwise to be pushed into another socket.

## Properties

| Property | Description |
| - | - |
| Start Locked | Player will not be able to use this prop_animinteractable until it unlocked.
| Return to Completion | When the player releases the handle, returns autonomously to the starting position.

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| Lock | Locks the interactable.
|| Unlock | Unlocks the interactable.
|| EnableReturnToCompletion | Interactable **will** autonomously return to starting position when let go.
|| DisableReturnToCompletion | Interactable **will *not*** autonomously return to starting position when let go.
| **Outputs**
|| OnPulledOutAtEnd | Player pulled the handle out of the ending socket.
|| OnPulledOutAtStart | Player pulled the handle out of the starting socket.
|| OnPushedInAtStart | Player pushed the handle into the starting socket.
|| OnPushedInAtEnd | Player pushed the handle into the ending socket.

---
<br>

## **combine_switch_pulltwist_alt**

> Has a turnable handle that the player can align to one of 5 selection points.

## Properties

| Property | Description |
| - | - |
| Start Locked | Player will not be able to use this prop_animinteractable until it unlocked.
| Return to Completion | When the player releases the handle, returns autonomously to the starting position.
| Resistance | Amount of resistance on movement (i.e. 1.0 no resistance, 0.1 strong resistance).

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| Lock | Locks the interactable.
|| Unlock | Unlocks the interactable.
|| EnableReturnToCompletion | Interactable **will** autonomously return to starting position when let go.
|| DisableReturnToCompletion | Interactable **will *not*** autonomously return to starting position when let go.
| **Outputs**
|| OnSelectorOn1 | Handle was aimed at the first selection point from any direction.
|| OnSelectorOn2 | Handle was aimed at the second selection point from any direction.
|| OnSelectorOn3 | Handle was aimed at the third selection point from any direction.
|| OnSelectorOn4 | Handle was aimed at the fourth selection point from any direction.
|| OnSelectorOn5 | Handle was aimed at the fifth selection point from any direction.
|| OnSelectorOff1 | Handle was aimed away from the first selection point in any direction.
|| OnSelectorOff2 | Handle was aimed away from the second selection point in any direction.
|| OnSelectorOff3 | Handle was aimed away from the third selection point in any direction.
|| OnSelectorOff4 | Handle was aimed away from the fourth selection point in any direction.
|| OnSelectorOff5 | Handle was aimed away from the fifth selection point in any direction.

---
<br>

## **combine_switch_pulltwist_alt_lights**

> A version of `combine_switch_pulltwist_alt.vmap` that includes color changing lights for each selector.

## Properties

| Property | Description |
| - | - |
| Start Locked | Player will not be able to use this prop_animinteractable until it unlocked.
| Return to Completion | When the player releases the handle, returns autonomously to the starting position.
| Resistance | Amount of resistance on movement (i.e. 1.0 no resistance, 0.1 strong resistance).
| Light Off Color | RGB color of each light when not aimed at by the handle.
| Light On Color | RGB color of each light when aimed at by the handle.
| Light Brightness | How bright the light props will glow:<br>`Normal`<br>`Super`

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| Lock | Locks the interactable.
|| Unlock | Unlocks the interactable.
|| EnableReturnToCompletion | Interactable **will** autonomously return to starting position when let go.
|| DisableReturnToCompletion | Interactable **will *not*** autonomously return to starting position when let go.
| **Outputs**
|| OnSelectorOn1 | Handle was aimed at the first selection point from any direction.
|| OnSelectorOn2 | Handle was aimed at the second selection point from any direction.
|| OnSelectorOn3 | Handle was aimed at the third selection point from any direction.
|| OnSelectorOn4 | Handle was aimed at the fourth selection point from any direction.
|| OnSelectorOn5 | Handle was aimed at the fifth selection point from any direction.
|| OnSelectorOff1 | Handle was aimed away from the first selection point in any direction.
|| OnSelectorOff2 | Handle was aimed away from the second selection point in any direction.
|| OnSelectorOff3 | Handle was aimed away from the third selection point in any direction.
|| OnSelectorOff4 | Handle was aimed away from the fourth selection point in any direction.
|| OnSelectorOff5 | Handle was aimed away from the fifth selection point in any direction.

---
<br>

## **combine_switch_slide**

> A small simple combine switch.

## Properties

| Property | Description |
| - | - |
| Start Locked | Player will not be able to use this prop_animinteractable until it unlocked.
| Return to Completion | When the player releases the handle, returns autonomously to the starting position.
| Resistance | Amount of resistance on movement (i.e. 1.0 no resistance, 0.1 strong resistance).

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| Lock | Locks the interactable.
|| Unlock | Unlocks the interactable.
|| EnableReturnToCompletion | Interactable **will** autonomously return to starting position when let go.
|| DisableReturnToCompletion | Interactable **will *not*** autonomously return to starting position when let go.
| **Outputs**
|| OnSwitchUp | Player moved the switch to the up position.
|| OnSwitchDown | Player moved the switch to the down position.

---
<br>

## **frankenswitch**

> A small lever switch.

## Properties

| Property | Description |
| - | - |
| Start Locked | Player will not be able to use this prop_animinteractable until it unlocked.
| Return to Completion | When the player releases the handle, returns autonomously to the starting position.
| Resistance | Amount of resistance on movement (i.e. 1.0 no resistance, 0.1 strong resistance).
| Motion style | How the animation behaves when it has returned to its starting position on release:<br>`Ease-in, ease-out`<br>`Ease-in only`<br>`Ease-out only`<br>`Bounce`<br>`Lerp`
| Body Type | The type of static prop present:<br>`Full`&emsp;&emsp;&ensp;Full backing plate and contact attachments.<br>`Minimal`&emsp;Single pair of contacts.<br>`None`&emsp;&emsp;&ensp;No static prop.

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| Lock | Locks the interactable.
|| Unlock | Unlocks the interactable.
|| EnableReturnToCompletion | Interactable **will** autonomously return to starting position when let go.
|| DisableReturnToCompletion | Interactable **will *not*** autonomously return to starting position when let go.
| **Outputs**
|| OnSwitchUp | Player moved the switch to the up position.
|| OnSwitchDown | Player moved the switch to the down position.

---
<br>

## **radioset_customizable**

> A version of the radioset found at the beginning of Half-Life: Alyx with customizable stations.

## Properties

| Property | Description |
| - | - |
| Station 1 | Sound to be played when player tunes to station 1.
| Station 1 | Sound to be played when player tunes to station 2.
| Station 1 | Sound to be played when player tunes to station 3.
| Static Sound | Sound to be played when player tunes to no station or has the antenna down.
| Save & Restore Stations | If the sound states should be restored on load, otherwise radio will need to be started on map load again.

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| StartRadio | Starts the radio sounds.
|| StopRadio | Stops the radio sounds.
|| MuteRadio | Radio sounds are paused and muted.
|| UnmuteRadio | Radio sounds are unpaused and unmuted.
| **Outputs**
|| OnStation1 | Player tuned the radio to station 1.
|| OnStation2 | Player tuned the radio to station 2.
|| OnStation3 | Player tuned the radio to station 3.
|| OnStatic | Player tuned the radio to no station, only static.

---
<br>

## **rollingdoor**

> A small single handed rolling door that the player can lift up and down.

## Properties

| Property | Description |
| - | - |
| Start Locked | Player will not be able to use this prop_animinteractable until it unlocked.
| Return to Completion | When the player releases the handle, returns autonomously to the starting position.
| Return to Completion Delay | Used when `Return to Completion` is enabled. If the animation had to return over its entire length, it'd take this long.
| Resistance | Amount of resistance on movement (i.e. 1.0 no resistance, 0.1 strong resistance).

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| Lock | Locks the interactable.
|| Unlock | Unlocks the interactable.
|| EnableReturnToCompletion | Interactable **will** autonomously return to starting position when let go.
|| DisableReturnToCompletion | Interactable **will *not*** autonomously return to starting position when let go.
| **Outputs**
|| OnOpened | Player lifted the door completely.
|| OnClosed | Player lowered the door completely.
|| OnOpenedHalfway | Player *lifted* the door to the half-way point.
|| OnClosedHalfway | Player *lowered* the door to the half-way point.

---
<br>

## **large_rollingdoor**

> A large two handed door that can be pulled up.

## Properties

| Property | Description |
| - | - |
| Start Locked | Player will not be able to use this prop_animinteractable until it unlocked.
| Return to Completion | When the player releases the handle, returns autonomously to the starting position.
| Resistance | Amount of resistance on movement (i.e. 1.0 no resistance, 0.1 strong resistance).
| Finish Completion Value | [0-1] value amount the player must lift the door for it to be considered open and finish the rest of the way.
| Hide Top Prop | Hides the static prop housing for the top of the door.
| Model Type | Type of model to be used:<br>`Standard`<br>`Holes`

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| Lock | Locks the interactable.
|| Unlock | Unlocks the interactable.
|| EnableReturnToCompletion | Interactable **will** autonomously return to starting position when let go.
|| DisableReturnToCompletion | Interactable **will *not*** autonomously return to starting position when let go.
| **Outputs**
|| OnLifted | Player lifted the door up to `Finish Completion Value` amount and will finish opening the rest of the way on its own.
|| OnFullyOpen | Door has finished opening completely.

---
<br>

## **window_apartment**

> A basic white apartment window that can be opened and closed.

## Properties

| Property | Description |
| - | - |
| Start Locked | Player will not be able to use this prop_animinteractable until it unlocked.
| Return to Completion | When the player releases the handle, returns autonomously to the starting position.
| Resistance | Amount of resistance on movement (i.e. 1.0 no resistance, 0.1 strong resistance).

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| Lock | Locks the interactable.
|| Unlock | Unlocks the interactable.
|| EnableReturnToCompletion | Interactable **will** autonomously return to starting position when let go.
|| DisableReturnToCompletion | Interactable **will *not*** autonomously return to starting position when let go.
| **Outputs**
|| OnOpened | Player lifted the window completely.
|| OnClosed | Player lowered the window completely.
|| OnOpenedHalfway | Player *lifted* the window to the half-way point.
|| OnClosedHalfway | Player *lowered* the window to the half-way point.

---