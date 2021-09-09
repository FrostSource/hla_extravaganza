# Health Station
by FrostSource

> ### A complete health station set-up including cables that can be extended by collapsing the prefab.

---

## Assets required

- maps\prefabs\gameplay\health_station\health_station.vmap

---

## Properties

| Property | Description |
| - | - |
| Hide Cables | Hides the four cables that come with the prefab.
| Hide Drip Overlay | Hides the combine drip overlay.
| Starts with Health Vial | Spawn with Health Vial already attached.
| Health Vial Level (0-1) | Sets the amount of health if the station starts with a Health Vial.

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| EnableCharger | Enables station use.
|| DisableCharger | Disables station use.
| **Outputs**
|| OnHealingPlayerStart | Fired when the station starts healing the player.
|| OnHealingPlayerStop | Fired when the station stops healing the player.
|| OnStationOpenReady | Fired when the station opens completely, has health remaining, and is ready to heal the player.
|| OnStationOpenNotReady | Fired when the station opens completely and is not enabled.

---