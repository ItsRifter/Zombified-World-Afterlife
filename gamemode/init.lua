--Server files
include("shared.lua")
include("server/player/sv_playerbase.lua")
include("server/player/sv_progress.lua")
include("server/filesaving/sv_flatfile.lua")
include("server/gameplay/sv_daycycle.lua")
include("server/gameplay/sv_npc.lua")
include("server/maps/sv_zombiespawns.lua")

--Client files
AddCSLuaFile("client/hud/cl_hud.lua")
AddCSLuaFile("client/hud/cl_scoreboard.lua")
AddCSLuaFile("client/cl_fonts.lua")
AddCSLuaFile("client/panels/cl_panels.lua")
AddCSLuaFile("client/menus/cl_qmenu.lua")
AddCSLuaFile("client/menus/cl_shopmenu.lua")

--Shared files
include("shared/skillbased/sh_playerskills.lua")
include("shared/database/sh_database.lua")
include("shared/database/sh_shopdealers.lua")
include("shared/database/sh_items.lua")
include("shared/player/sh_inventory.lua")

--Network
util.AddNetworkString("ZWR_BroadcastMessage")
util.AddNetworkString("ZWR_BroadcastSound")
util.AddNetworkString("ZWR_OpenShop")
