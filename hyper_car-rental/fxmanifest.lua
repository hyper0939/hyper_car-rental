fx_version("cerulean")
game("gta5")

description("Car Rental")
author("hyper0939")
version("0.0.1")

client_scripts({
	"Code/client-side.lua",
})

server_scripts({
	"Code/server-side.lua",
})

shared_scripts({
	"config.lua",
})

ui_page("UI/index.html")

files({
	"UI/*html",
	"UI/*.css",
	"UI/*.js",
	"UI/images/*.svg",
})
