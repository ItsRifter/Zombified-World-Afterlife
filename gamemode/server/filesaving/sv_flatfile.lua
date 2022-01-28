local function InitData(ply)
    ply.ZWR = ply.ZWR or {}

    --Basics
    ply.ZWR.Name = ply.ZWR.Name or ply:Nick()
	ply.ZWR.Model = ply.ZWR.Model or "models/player/Group01/male_07.mdl"
    
    --Leveling etc.
    ply.ZWR.Level = ply.ZWR.Level or 0
    ply.ZWR.Money = ply.ZWR.Money or 0
    ply.ZWR.EXP = ply.ZWR.EXP or 0
	ply.ZWR.ReqEXP = ply.ZWR.ReqEXP or 2500

    --Inventory
    ply.ZWR.Inventory = ply.ZWR.Inventory or {}
	ply.ZWR.InvMaxSlotsWidth = ply.ZWR.InvMaxSlotsWidth or 5
	ply.ZWR.InvMaxSlotsHeight = ply.ZWR.InvMaxSlotsHeight or 6

    --Skills
    ply.ZWR.Skills = ply.ZWR.Skills or {}
	ply.ZWR.SkillPoints = ply.ZWR.SkillPoints or 0

	--Statuses
	ply.ZWR.LastHealth = ply.ZWR.LastHealth or 100
	ply.ZWR.Hunger = ply.ZWR.Hunger or 100
	ply.ZWR.Thirst = ply.ZWR.Thirst or 100
	ply.ZWR.Infection = ply.ZWR.Infection or 0
	--Effects is an active effect like bleeding or radiation
	ply.ZWR.Effects = ply.ZWR.Effects or {}
end

local function CreateData(ply)
	local PlayerID = string.Replace(ply:SteamID(), ":", "!")
	
	-- Create and init persistent data fields
	InitData(ply)
	
	-- Store all persistent data as JSON
	file.Write("zwr_data/" .. PlayerID .. ".txt", util.TableToJSON(ply.ZWR, true))
end

local function LoadData(ply)
	local PlayerID = string.Replace(ply:SteamID(), ":", "!")
	local jsonContent = file.Read("zwr_data/" .. PlayerID .. ".txt", "DATA")
	if not jsonContent then return false end

	-- Read persistent data from JSON
	ply.ZWR = util.JSONToTable(jsonContent)

	-- Init not set fields of persistent data
	InitData(ply)
	
	-- Init player model and other stuff
	ply:SetModel(ply.ZWR.Model)
	
	return true -- Return true to signal that the settings could be loaded
end

local function SavePlayerData(ply)
	local PlayerID = string.Replace(ply:SteamID(), ":", "!")

	-- Store all persistent data as JSON
	file.Write("zwr_data/" .. PlayerID .. ".txt", util.TableToJSON(ply.ZWR, true))
	
end

--If there isn't a ZWR data folder, create one
hook.Add("Initialize", "CreateDataFolder", function()
	if GAMEMODE.MYSQL.Data.Type ~= "txt" then return end
	
	if not file.IsDir( "zwr_data", "DATA") then
		print("MISSING ZW:R FOLDER: Making new one")
		file.CreateDir("zwr_data", "DATA")
	end
end)

--When the player disconnects, save their data
hook.Add("PlayerDisconnected", "ZWR_SavePlayerDataDisconnect", function(ply) 
	if GAMEMODE.MYSQL.Data.Type == "txt" then
		SavePlayerData(ply)
	end

	for i, f in pairs(CURRENT_FACTIONS) do
		if ply == f.owner then
			net.Start("ZWR_Faction_Discard_Server")
				net.WriteString(f.name)
			net.Broadcast()

			table.remove(CURRENT_FACTIONS, i)
		end
	end
end)

--Upon a map change or server shutdown, save everyones progress
hook.Add( "ShutDown", "ZWR_MapChangeSave", function()
	--If we aren't using TXT format saving, stop here
	if GAMEMODE.MYSQL.Data.Type ~= "txt" then return end

	for _, ply in ipairs( player.GetAll() ) do
		SavePlayerData(ply)
	end
end)

hook.Add("PlayerAuthed", "ZWR_PlayerAuth", function(ply, steamid, uniqueid)
	--If the save format isn't set to MySQL, stop here
	if GAMEMODE.MYSQL.Data.Type ~= "mysql" then return end

	SaveSystem:LoadPlayerData(ply)

end)

hook.Add("PlayerInitialSpawn", "ZWR_NewPlayerCheck", function(ply)
	--If the player is a bot, set model to kleiner and stop there
	if ply:IsBot() then
		ply:SetModel("models/player/kleiner.mdl")
		return
	end

	if GAMEMODE.MYSQL.Data.Type ~= "txt" then return end

	--If its a new player, create a save file for saving (and ensuring the player isn't a bot)
	if not LoadData(ply) and not ply:IsBot() then
		CreateData(ply)
		NewPlayerInventory(ply)
		return
	end
	
	--If its a returning player, load their save file
	LoadData(ply)
end)
