--Server files
include("shared.lua")
include("server/player/sv_playerbase.lua")
include("server/player/sv_progress.lua")
include("server/player/sv_player_faction.lua")
include("server/filesaving/sv_flatfile.lua")
include("server/gameplay/sv_daycycle.lua")
include("server/gameplay/sv_npc.lua")
include("server/gameplay/sv_convars.lua")
include("server/maps/sv_npcspawnpoints.lua")

--Client files
AddCSLuaFile("client/hud/cl_hud.lua")
AddCSLuaFile("client/hud/cl_scoreboard.lua")
AddCSLuaFile("client/cl_fonts.lua")
AddCSLuaFile("client/panels/cl_panels.lua")
AddCSLuaFile("client/menus/cl_qmenu.lua")
AddCSLuaFile("client/menus/cl_shopmenu.lua")
AddCSLuaFile("client/menus/cl_basebuilding.lua")

--Shared files
include("shared/skillbased/sh_playerskills.lua")
include("shared/database/sh_database.lua")
include("shared/database/sh_items.lua")
include("shared/database/sh_buildings.lua")

--Network
util.AddNetworkString("ZWR_BroadcastMessage")
util.AddNetworkString("ZWR_BroadcastSound")

--Shop
util.AddNetworkString("ZWR_OpenShop")

--Buying/Selling
util.AddNetworkString("ZWR_BuyItem")
util.AddNetworkString("ZWR_SellItem")
util.AddNetworkString("ZWR_Shop_UpdateCash")

--Inventory
util.AddNetworkString("ZWR_Inventory_UseItem")
util.AddNetworkString("ZWR_Inventory_DropItem")
util.AddNetworkString("ZWR_Inventory_DropItem_Client")
util.AddNetworkString("ZWR_Inventory_Init")
util.AddNetworkString("ZWR_Inventory_ArrangeItem")
util.AddNetworkString("ZWR_Inventory_UpdateItem")
util.AddNetworkString("ZWR_Inventory_Refresh_Standard")
util.AddNetworkString("ZWR_Inventory_Refresh_Remove")
util.AddNetworkString("ZWR_Inventory_Refresh_Add")

--Faction
util.AddNetworkString("ZWR_Faction_Create")
util.AddNetworkString("ZWR_Faction_Create_Server")
util.AddNetworkString("ZWR_Faction_Join")
util.AddNetworkString("ZWR_Faction_Join_Server")
util.AddNetworkString("ZWR_Faction_Discard")
util.AddNetworkString("ZWR_Faction_Discard_Server")
util.AddNetworkString("ZWR_Faction_Update")
util.AddNetworkString("ZWR_Faction_Leave")
util.AddNetworkString("ZWR_Faction_Leave_Server")
util.AddNetworkString("ZWR_Faction_Invited")

--Faction base related 
util.AddNetworkString("ZWR_FactionBase_InvestFunds")
util.AddNetworkString("ZWR_FactionBase_InvestFunds_Server")

--TEMPORARY, will remove once JMOD is supported with ZW:R
concommand.Add("zwr_resetcraft", function(ply)
    if not ply:IsSuperAdmin() then return end
    
    JMod.InitGlobalConfig(true)
end)