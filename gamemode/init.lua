--Server files
include("shared.lua")

//Network
include("server/sv_networking.lua")

//Resource
include("server/sv_resources.lua")

//Player
include("server/playerbase/sv_player.lua")

//NPC
include("server/npcbase/sv_npc.lua")
include("server/npcbase/sv_npc_mapsetup.lua")

//Map Setup
include("server/maps/sv_maps.lua")

//Data saving
include("server/datastorage/sv_flatfile.lua")

//Convar
include("server/sv_convars.lua")

//Client files
AddCSLuaFile("client/hudbased/cl_zwa_hud.lua")
AddCSLuaFile("client/panels/cl_themes.lua")
AddCSLuaFile("client/panels/cl_fonts.lua")
AddCSLuaFile("client/panels/cl_panels.lua")
AddCSLuaFile("client/hudbased/cl_zwa_tabmenu.lua")
AddCSLuaFile("client/hudbased/cl_zwa_weaponwheel.lua")

//Shared files
include("shared/playerbase/sh_player.lua")
AddCSLuaFile("shared/playerbase/sh_player.lua")