# Combine Console Fingers
by FrostSource

> ### A copy of maps/release/prefabs/entities/combine_console.vmap but with inputs to start/stop the metal fingers on the sides animating.

> Requested by `Dumoria` at `Source 2 : Modding Hub`

---

## Assets required

- maps\prefabs\gameplay\combine_console_fingers\combine_console_fingers.vmap

---

## Properties

| Property | Description |
| - | - |
| Hide Sphere 1 | Hides hacking sphere 1.
| Hide Sphere 2 | Hides hacking sphere 2.
| Hide Sphere 3 | Hides hacking sphere 3.
| Tank1 Missing | Tank 1 will start missing from the console.
| Tank2 Missing | Tank 2 will start missing from the console.
| Tank3 Missing | Tank 3 will start missing from the console.
| Tank4 Missing | Tank 4 will start missing from the console.
| Start Hidden  | Console will not start spawned in the world.
| HackDifficultyName | The difficulty name for the hack:<br>First<br>Easy<br>Medium<br>Hard<br>VeryHard<br><br>Other names exist in `pak01_dir.vpk/scripts/holo_hacking_difficulty.txt`.
| Objective Model | Unknown.
| Rack1 Active | Rack 1 will be visible and interactable.
| Rack2 Active | Rack 2 will be visible and interactable.
| Rack3 Active | Rack 3 will be visible and interactable.
| Rack4 Active | Rack 4 will be visible and interactable.
| Puzzle Type | The type of puzzle the player must complete to open up the crafting station.
| Start Hacked | If `Yes` the console will open up automatically when spawned.

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| AnimateFingers | Animates the fingers models without wating for console to open.
|| Enable | Enables the hacking plug.
|| Disable | Disables the hacking plug.
|| ForceHacked | Forces the console to open.
|| Reveal | Spawns the console and plug into the world.
|| StopFingers | Stops the fingers animation.
|| SuppressBlindZombieSound | Prevent the console from attracting the blind zombie while the player is hacking it (parameter is 1 or 0 to turn suppression on/off).
| **Outputs**
|| OnBatteryPlaced | Fired when the console battery has been added.
|| OnClosed | Fired when the console has been closed.
|| OnCompleted | Fired when the console has been activated.
|| OnHackFailed | Fires when the hack has failed.
|| OnHackStarted | Fires when the hack has been started.
|| OnOpened | Fired when the console has been opened without the battery.
|| OnTankAdded | Fired when a missing console tank has been added.
|| OnTimeout | Fired when the console timeout has been triggered.

---