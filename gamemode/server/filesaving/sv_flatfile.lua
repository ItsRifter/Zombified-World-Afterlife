local function InitData(ply)
    ply.ZWR = ply.ZWR or {}

    --Basics
    ply.ZWR.Name = ply.ZWR.Name or ply:Nick()
	ply.ZWR.Model = ply.ZWR.Model or "models/player/Group01/male_07.mdl"
    
    --Leveling etc.
    ply.ZWR.Level = ply.ZWR.Level or 0
    ply.ZWR.Money = ply.ZWR.Money or 0
    ply.ZWR.EXP = ply.ZWR.EXP or 0

    --Inventory
    ply.ZWR.Inventory = ply.ZWR.Inventory or {}
    
    --Skills
    ply.ZWR.Skills = ply.ZWR.Skills or {}
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

--If there isn't a HL2CR data folder, create one
hook.Add("Initialize", "CreateDataFolder", function()
	if not file.IsDir( "zwr_data", "DATA") then
		print("MISSING ZW:R FOLDER: Making new one")
		file.CreateDir("zwr_data", "DATA")
	end
end)

--When the player disconnects, save their data
hook.Add("PlayerDisconnected", "HL2CR_SavePlayerDataDisconnect", function(ply) 
	SavePlayerData(ply)
end)

--Upon a map change or server shutdown, save everyones progress
hook.Add( "ShutDown", "HL2CR_MapChangeSave", function() 
	for _, ply in ipairs( player.GetAll() ) do
		SavePlayerData(ply)
	end
end)

hook.Add("PlayerInitialSpawn", "HL2CR_NewPlayerCheck", function(ply)
	--If the player is a bot, set model to kleiner and stop there
	if ply:IsBot() then
		ply:SetModel("models/player/kleiner.mdl")
		return
	end

	--If its a new player, create a save file for saving (and ensuring the player isn't a bot)
	if not LoadData(ply) and not ply:IsBot() then
		CreateData(ply)
		return
	end
	
	--If its a returning player, load their save file
	LoadData(ply)
end)
