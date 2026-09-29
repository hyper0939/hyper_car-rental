# Hyper's Car Rental
<img width="500" height="400" alt="Car Rental" src="https://github.com/user-attachments/assets/4319d027-6ea1-43c9-bca9-289479782482" />

A vehicle rental system for FiveM featuring a custom NUI design. Players rent vehicles at a rental point, pay per minute, and return the vehicle at a drop-off point.

## Features

- Custom interface (HTML/CSS/JS); vehicle list loaded dynamically from the config.
- Per-minute billing (adjustable interval)
- Supports **ESX**, **QBCore**, and **Standalone** (no money deduction, for testing purposes)
- Multiple rental stations with dedicated spawn and return points.
- Blips, markers, and help texts
- Server-side checks (distance, money, vehicle data, only one rental per player)
- Automatic cleanup upon disconnection or resource stop

## Requirements

- FiveM server with **OneSync** (`set onesync on` in the `server.cfg`)
- One of: `es_extended` (ESX), `qb-core` (QBCore), or no framework (Standalone)

## Operation

1. Go to the rental point (yellow marker) and press **E**.
2. Select the vehicle from the list and click **RENT**.
3. The vehicle spawns at the spawn point, and the player is placed inside it.
4. Drive to the return point (red marker) and press **E**.
5. The vehicle is deleted, and billing ends.

If the funds are insufficient at the time of settlement, the vehicle is automatically impounded.

## Adjustments

### Integrate Fuel script

Enter the appropriate export in the `SetFuel` function within `client-side.lua`, for example:

```lua
exports['LegacyFuel']:SetFuel(vehicle, amount)
-- or
Entity(vehicle).state.fuel = amount   -- ox_fuel
```

### Integrate key script

In `client-side.lua`, within the `hyper_rental:Rented` event, the location for vehicle keys is marked—for example:

```lua
exports['qb-vehiclekeys']:SetVehicleKey(GetVehicleNumberPlateText(vehicle), true)
```

### Payment by bank transfer

In the `server.lua` file within the framework bridge (`Bridge.RemoveMoney` / `Bridge.AddMoney`), use the bank account instead of cash—for example, `xPlayer.getAccount('bank')` for ESX and `'bank'` instead of `'cash'` for QBCore.
