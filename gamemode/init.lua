--Server files
include("shared.lua")
include("server/player/sv_playerbase.lua")
include("server/filesaving/sv_flatfile.lua")

--Client files
AddCSLuaFile("client/hud/cl_hud.lua")
AddCSLuaFile("client/hud/cl_scoreboard.lua")
AddCSLuaFile("client/cl_fonts.lua")
AddCSLuaFile("client/panels/cl_panels.lua")
AddCSLuaFile("client/menus/cl_qmenu.lua")

--Shared files
include("shared/skillbased/sh_playerskills.lua")
