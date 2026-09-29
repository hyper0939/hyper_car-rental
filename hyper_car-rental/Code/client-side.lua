---@diagnostic disable: param-type-mismatch, undefined-global
local isOpen = false
local currentLocation = nil
local rentedNetId = nil

--// Help Functions \\--
local function Notfiy(msg)
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandThefeedPostTicker(false, true)
end

local function HelpText(msg)
	BeginTextCommandDisplayHelp("STRING")
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandDisplayHelp(0, false, true, -1)
end

local function SetFuel(vehicle, amount)
	exports["LegacyFuel"]:SetFuel(vehicle, amount)

	--SetVehicleFuelLevel(vehicle, amount + 0.0)
end

local function OpenUI()
	if isOpen then
		return
	end
	isOpen = true

	SetNuiFocus(true, true)
	SendNUIMessage({
		action = "Open",
		vehicles = Config.Vehicles,
	})
end

local function CloseUI()
	if not isOpen then
		return
	end
	isOpen = false

	SetNuiFocus(false, false)
	SendNUIMessage({
		action = "Hide",
	})
end

--// NUI Callbacks \\--
RegisterNUICallback("Close", function(_, cb)
	CloseUI()
	cb("ok")
end)

RegisterNUICallback("Rent", function(data, cb)
	if data and data.Model and currentLocation then
		TriggerServerEvent("hyper_rental:Rent", data.Model, currentLocation)
	end
	cb("ok")
end)

--// Server Events \\--
RegisterNetEvent("hyper_rental:Notify", Notify)

RegisterNetEvent("hyper_rental:Rented", function(netId, fuel)
	CloseUI()

	local timeout = GetGameTimer() + 5000
	while not NetworkDoesNetworkIdExist(netId) and GetGameTimer() < timeout do
		Wait(50)
	end

	local vehicle = NetworkGetEntityFromNetworkId(netId)
	if vehicle == 0 or not DoesEntityExist(vehicle) then
		return
	end

	rentedNetId = netId
	SetFuel(vehicle, fuel)
	SetVehicleEngineOn(vehicle, true, true, false)
	TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)

	--// Keys \\--
end)

RegisterNetEvent("hyper_rental:Ended", function()
	rentedNetId = nil
end)

--// Blips \\--
CreateThread(function()
	for _, loc in ipairs(Config.Locations) do
		local blip = AddBlipForCoord(loc.coords.x, loc.coords.y, loc.coords.z)
		SetBlipSprite(blip, loc.blip.Sprite)
		SetBlipColour(blip, loc.blip.Color)
		SetBlipScale(blip, loc.blip.Scale)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentSubstringPlayerName(loc.label)
		EndTextCommandSetBlipName(blip)
	end
end)

--// Interactions \\--
CreateThread(function()
	while true do
		local sleep = 1000
		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)

		for i, loc in ipairs(Config.Locations) do
			local dist = #(coords - loc.coords)

			if dist < 15.0 then
				sleep = 0
				DrawMarker(
					36,
					loc.coords.x,
					loc.coords.y,
					loc.coords.z,
					0.0,
					0.0,
					0.0,
					0.0,
					0.0,
					0.0,
					0.8,
					0.8,
					0.8,
					255,
					255,
					0,
					150,
					false,
					true,
					2,
					false,
					nil,
					nil,
					false
				)

				if dist < 1.5 and not isOpen and not IsPedInAnyVehicle(ped, false) then
					HelpText(Config.Text.OpenMenu)
					if IsControlJustReleased(0, 38) then
						currentLocation = i
						OpenUI()
					end
				end
			end

			if rentedNetId then
				local rc = loc.returnCoords
				local rDist = #(coords - rc)

				if rDist < 30.0 then
					sleep = 0
					DrawMarker(
						36,
						rc.x,
						rc.y,
						rc.z,
						0.0,
						0.0,
						0.0,
						0.0,
						0.0,
						0.0,
						0.8,
						0.8,
						0.8,
						255,
						50,
						50,
						120,
						false,
						true,
						2,
						false,
						nil,
						nil,
						false
					)

					if rDist < 3.0 then
						local veh = GetVehiclePedIsIn(ped, false)

						if veh ~= 0 and NetworkGetNetworkIdFromEntity(veh) == rentedNetId then
							HelpText(Config.Text.ReturnVehicle)
							if IsControlJustReleased(0, 38) then
								TaskLeaveVehicle(ped, veh, 0)
								TriggerServerEvent("hyper_rental:Return")
							end
						end
					end
				end
			end
		end
		Wait(sleep)
	end
end)

AddEventHandler("onResourceStop", function(res)
	if res == GetCurrentResourceName() and isOpen then
		SetNuiFocus(false, false)
	end
end)
