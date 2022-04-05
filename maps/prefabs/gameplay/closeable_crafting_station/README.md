# Closeable Crafting Station
by FrostSource

> ### A modified `maps/release/prefabs/entities/crafting_station.vmap` prefab which allows for powering the station off as well as adding other inputs that were missing.

---

## Assets required

- maps\prefabs\gameplay\closeable_crafting_station\closeable_crafting_station.vmap

---

## Properties

| Property | Description |
| - | - |
| IsPowered | The station and hacking plug start powered on map start.
| Hide Spawn 1-10 | Hacking spawn spots can be individually enabled/disabled.
| HackDifficultyName | The difficulty name for the hack:<br>First<br>Easy<br>Medium<br>Hard<br>VeryHard<br><br>Other names exist in `pak01_dir.vpk/scripts/holo_hacking_difficulty.txt`.
| Puzzle Type | The type of puzzle the player must complete to open up the crafting station.
| DisableAnimationOutputs | The last 9 outputs listed below will not fire. Avoids any performance cost that may occur on map start (unlikely to ever be noticed).
| Starts Hacked | Station will open when the player is near without needing a hack.

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| PowerOn | Powers the station and hacking plug on, opening it up completely if the hack was previously completed.
|| PowerOff | Powers the station and hacking plug off and closes the machine. If the station is completely open the closing animation will look jarring so should be powered down out of view.
|| ForceOpen | Open the station. Skips the hacking plug puzzle and opens the station immediately.
|| ReturnWeapon | Powers the station and hacking plug on.
| **Outputs**
|| OnPlayerNear | Fires when the player is near the station before it has been hacked and opened.
|| OnHackSuccess | Fires when the hack has been successfully completed.
|| OnHackFailed | Fires when the hack has failed.
| **Animation Outputs**
|| OnConsoleStartedOpening | The main console has started its opening animation.
|| OnConsoleScreenOpened | The interactive screen has finished opening.
|| OnCradleStartedOpening | Weapon cradle opening animation started.
|| OnCradleFinishedOpening | Weapon cradle opening animation finished.
|| OnTrayInteraction | Player placed or retrieved resin from the tray.
|| OnResinFinished | Player finished placing resin and tray is closing.
|| OnUpgradeStarted | Weapon upgrade animation has started.
|| OnUpgradeFinished | Weapon upgrade animation has finished but weapon is still enclosed.
|| OnWeaponReady | Upgrading has finished completely and weapon can be taken.

---