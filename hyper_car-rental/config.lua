Config = {}

--// "ESX" | "QBcore" | "Standalone"
Config.Framework = "ESX"

Config.BillingInterval = 60000 -- Every minute

Config.Locations = {
	{
		label = "Car Rental",
		coords = vec3(407.5313, -1625.4120, 29.2920),
		spawn = vec4(401.1464, -1631.0222, 29.2920, 228.4214),
		returnCoords = vec3(398.5774, -1636.8701, 29.2920),
		blip = {
			Sprite = 225,
			Color = 5,
			Scale = 0.8,
		},
	},
}

Config.Vehicles = {
	{ model = "blista", label = "BLISTA", price = 50, fuel = 60 },
	{ model = "sultan", label = "SULTAN", price = 100, fuel = 70 },
	{ model = "kuruma", label = "KURUMA", price = 150, fuel = 80 },
	{ model = "bati", label = "BATI 801", price = 120, fuel = 30, type = "bike" },
	{ model = "240NismoTT", label = "240 Nismo TT", price = 250, fuel = 50 },
	{ model = "720spiderb", label = "720 Spider", price = 350, fuel = 35 },
	{ model = "e63amgb", label = "E63 AMG", price = 200, fuel = 55 },
}

Config.Text = {
	OpenMenu = "~INPUT_CONTEXT~ Fahrzeug mieten",
	ReturnVehicle = "~INPUT_CONTEXT~ Fahrzeug zurückgeben",
}
