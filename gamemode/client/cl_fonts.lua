--TEMPLATE
--[[
	surface.CreateFont( "TEMPLATE", {
		font = "Roboto",
		extended = false,
		size = 32,
		weight = 150,
		blursize = 0,
		scanlines = 0,
		antialias = false,
		underline = false,
		italic = false,
		strikeout = false,
		symbol = false,
		rotary = false,
		shadow = false,
		additive = false,
		outline = false,
	} )

--]]

--HUD Fonts
surface.CreateFont( "ZWR_HUD_Health", {
	font = "Roboto",
	extended = false,
	size = 32,
	weight = 150,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	outline = true,
} )

surface.CreateFont( "ZWR_HUD_Stamina", {
	font = "Roboto",
	extended = false,
	size = 26,
	weight = 125,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	outline = true,
} )

surface.CreateFont( "ZWR_HUD_Faction", {
	font = "Roboto",
	extended = false,
	size = 42,
	weight = 150,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	outline = true,
} )

--Q-Menu Fonts
surface.CreateFont( "ZWR_QMenu_ButtonText", {
	font = "Roboto",
	extended = false,
	size = 24,
	weight = 150,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	outline = true,
} )

--Scoreboard
surface.CreateFont( "ZWR_Scoreboard_Nickname", {
	font = "Roboto",
	extended = false,
	size = 24,
	weight = 350,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

surface.CreateFont( "ZWR_Scoreboard_Stats", {
	font = "Arial",
	extended = false,
	size = 20,
	weight = 250,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )

--NPC
surface.CreateFont( "ZWR_NPC_Name", {
	font = "Arial",
	extended = false,
	size = 20,
	weight = 250,
	blursize = 0,
	scanlines = 0,
	antialias = true,
} )
