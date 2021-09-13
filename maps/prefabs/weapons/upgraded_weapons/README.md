# Weapons With Upgrades
by FrostSource

> ### A prefab for each of the 3 base weapons with options to start with upgrades so players can pick up an upgraded weapon without the visual jarring of upgrades appearing suddenly.

> More details if needed.

---

## Assets required

- maps\prefabs\weapons\upgraded_weapons\energygun_with_upgrades.vmap
- maps\prefabs\weapons\upgraded_weapons\rapidfire_with_upgrades.vmap
- maps\prefabs\weapons\upgraded_weapons\shotgun_with_upgrades.vmap

---

## **Energygun**

## Properties

| Property | Description |
| - | - |
| Give Item Holder | If the wrist holders should be enabled or disabled when player picks up the weapon.
| Enable Backpack | If the backpack should be enabled or disabled when the player picks up the weapon.
| Hide Decor | This visual attachment is present for all 4 upgrades so the option is there to hide it if you choose no upgrades.
| Number of bullets in the clip (Default is no clip) | Pistol will start with this amount of bullets in the magazine, or -1 or no magazine.
| Start Asleep | The weapon prop starts asleep.
| Laser Sight Upgrade | If `Yes` the weapon will start with the models for this upgrade attached and player will recieve the upgrades when picking up the weapon.
| Reflex Sight Upgrade | If `Yes` the weapon will start with the models for this upgrade attached and player will recieve the upgrades when picking up the weapon.
| Bullet Hopper Upgrade | If `Yes` the weapon will start with the models for this upgrade attached and player will recieve the upgrades when picking up the weapon.
| Burst Fire Upgrade | If `Yes` the weapon will start with the models for this upgrade attached and player will recieve the upgrades when picking up the weapon.

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| ForceSpawn | Spawns the weapon and all related entities.
| **Outputs**
|| OnPlayerPickup | Fires when the player picks up the weapon with any hand.
|| OnGlovePulled | Fires when the weapon is pulled by the grabbity gloves.
|| OnAttachedToHand | Fires when the weapon is picked up by the player's dominant hand.

---

## **Shotgun**

## Properties

| Property | Description |
| - | - |
| Give Item Holder | If the wrist holders should be enabled or disabled when player picks up the weapon.
| Enable Backpack | If the backpack should be enabled or disabled when the player picks up the weapon.
| Start Asleep | The weapon prop starts asleep.
| Autoloader Upgrade | If `Yes` the weapon will start with the models for this upgrade attached and player will recieve the upgrades when picking up the weapon.
| Grenade Launcher Upgrade | If `Yes` the weapon will start with the models for this upgrade attached and player will recieve the upgrades when picking up the weapon.
| Laser Sight Upgrade Upgrade | If `Yes` the weapon will start with the models for this upgrade attached and player will recieve the upgrades when picking up the weapon.
| Quick Fire Upgrade | If `Yes` the weapon will start with the models for this upgrade attached and player will recieve the upgrades when picking up the weapon.

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| ForceSpawn | Spawns the weapon and all related entities.
| **Outputs**
|| OnPlayerPickup | Fires when the player picks up the weapon with any hand.
|| OnGlovePulled | Fires when the weapon is pulled by the grabbity gloves.
|| OnAttachedToHand | Fires when the weapon is picked up by the player's dominant hand.

---

## **Rapidfire**

## Properties

| Property | Description |
| - | - |
| Give Item Holder | If the wrist holders should be enabled or disabled when player picks up the weapon.
| Enable Backpack | If the backpack should be enabled or disabled when the player picks up the weapon.
| Start Asleep | The weapon prop starts asleep.
| Reflex Sight Upgrade | If `Yes` the weapon will start with the models for this upgrade attached and player will recieve the upgrades when picking up the weapon.
| Laser Sight Upgrade | If `Yes` the weapon will start with the models for this upgrade attached and player will recieve the upgrades when picking up the weapon.
| Extended Magazine Upgrade | If `Yes` the weapon will start with the models for this upgrade attached and player will recieve the upgrades when picking up the weapon.

---

## Input / Output

|| Name | Description |
| -: | - | - |
| **Inputs**
|| ForceSpawn | Spawns the weapon and all related entities.
| **Outputs**
|| OnPlayerPickup | Fires when the player picks up the weapon with any hand.
|| OnGlovePulled | Fires when the weapon is pulled by the grabbity gloves.
|| OnAttachedToHand | Fires when the weapon is picked up by the player's dominant hand.

---
