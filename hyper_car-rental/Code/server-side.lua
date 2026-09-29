local Rentals = {}
local Busy = {}

--// Framework
local Bridge = {}

if Config.Framework == "ESX" then
	local ESX = exports["es_extended"]:getSharedObject()

	Bridge.RemoveMoney = function(src, amount)
		local xPlayer = ESX.GetPlayerFromId(src)
		if not xPlayer or xPlayer.getMoney() < amount then
			return false
		end

		xPlayer.removeMoney(amount)

		return true
	end

	Bridge.AddMoney = function(src, amount)
		local xPlayer = ESX.GetPlayerFromId(src)
		if xPlayer then
			xPlayer.addMoney(amount)
		end
	end
elseif Config.Framework == "QBCore" then
	local QBCore = exports["qb-core"]:GetCoreObject()

	Bridge.RemoveMoney = function(src, amount)
		local player = QBCore.Functions.GetPlayer(src)
		if not player or player.PlayerData.money.cash < amount then
			return false
		end

		player.Functions.RemoveMoney("cash", amount)

		return true
	end

	Bridge.AddMoney = function(src, amount)
		local player = QBCore.Functions.GetPlayer(src)
		if player then
			player.Functions.AddMoney("cash", amount)
		end
	end
else
	Bridge.RemoveMoney = function()
		return true
	end

	Bridge.AddMoney = function() end
end

--// Help Functions \\--
local function Notify(src, msg)
	TriggerClientEvent("hyper_rental:Notify", src, msg)
end

local function GetVehicleConfig(model)
	for _, v in ipairs(Config.Vehicles) do
		if v.model == model then
			return v
		end
	end
end

local function EndRental(src, msg)
	local rental = Rentals[src]
	if not rental then
		return
	end

	if rental.Entity and DoesEntityExist(rental.Entity) then
		DeleteEntity(rental.Entity)
	end

	Rentals[src] = nil

	TriggerClientEvent("hyper_rental:Ended", src)

	if msg then
		Notify(src, msg)
	end
end

--// Rent \\--
RegisterNetEvent("hyper_rental:Rent", function(model, locIndex)
	local src = source

	if type(model) ~= "string" then
		return
	end
	if Busy[src] then
		return
	end
	if Rentals[src] then
		return Notify(src, "Du hast bereits ein Mietfahrzeug.")
	end

	local loc = Config.Locations[tonumber(locIndex) or 0]
	if not loc then
		return
	end

	local ped = GetPlayerPed(src)
	if #(GetEntityCoords(ped) - loc.coords) > 10.0 then
		return
	end

	local veh = GetVehicleConfig(model)
	if not veh then
		return
	end

	Busy[src] = true

	if not Bridge.RemoveMoney(src, veh.price) then
		Busy[src] = nil
		return Notify(src, "Du hast nicht genug Geld.")
	end

	local spawn = loc.spawn
	local entity =
		CreateVehicleServerSetter(joaat(veh.model), veh.type or "automobile", spawn.x, spawn.y, spawn.z, spawn.w)
	local tries = 0
	while not DoesEntityExist(entity) and tries < 50 do
		Wait(100)
		tries += 1
	end

	if not DoesEntityExist(entity) then
		Bridge.AddMoney(src, veh.price)
		Busy[src] = nil
		return Notify(src, "Fahrzeug konnte nicht gespawnt werden")
	end

	SetVehicleNumberPlateText(entity, ("RENT%03d"):format(math.random(0, 999)))

	Rentals[src] = {
		Entity = entity,
		Model = veh.model,
		Price = veh.price,
		Total = veh.price,
		StartTime = os.time(),
	}
	Busy[src] = nil

	TriggerClientEvent("hyper_rental:Rented", src, NetworkGetNetworkIdFromEntity(entity), veh.fuel)
	Notify(src, ("Du hast %s gemietet. Kosten: $%d/min"):format(veh.label, veh.price))
end)

--// Bringing back the vehicle \\--
RegisterNetEvent("hyper_rental:Return", function()
	local src = source
	local rental = Rentals[src]
	if not rental then
		return
	end

	local pedCoords = GetEntityCoords(GetPlayerPed(src))
	local nearReturn = false
	for _, loc in ipairs(Config.Locations) do
		if #(pedCoords - loc.returnCoords) < 15.0 then
			nearReturn = true
			break
		end
	end

	if not nearReturn then
		return
	end

	EndRental(src, ("Fahrzeug zurückgegeben. Gesamtkosten: $%d"):format(rental.Total))
end)

--// Billing \\--
CreateThread(function()
	while true do
		Wait(Config.BillingInterval)

		for src, rental in pairs(Rentals) do
			if Bridge.RemoveMoney(src, rental.Price) then
				rental.Total += rental.Price
				Notify(src, ("Mietkosten: -$%d"):format(rental.Price))
			else
				EndRental(src, "Du konntest die Miete nicht bezahlen. Das Fahrzeug wurde eingezogen.")
			end
		end
	end
end)

--// Cleanup \\--
AddEventHandler("playerDropped", function()
	local src = source
	Busy[src] = nil
	EndRental(src)
end)

AddEventHandler("onResourceStop", function(res)
	if res ~= GetCurrentResourceName() then
		return
	end

	for src in pairs(Rentals) do
		EndRental(src)
	end
end)
