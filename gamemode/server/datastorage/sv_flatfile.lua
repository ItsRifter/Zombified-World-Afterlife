local function InitData(ply)
    ply.zwa = ply.zwa or {}

    --Basics
    ply.zwa.Name = ply.zwa.Name or ply:Nick()
	ply.zwa.Model = ply.zwa.Model or "models/player/Group01/male_07.mdl"
    
    --Levelling etc.
    ply.zwa.Level = ply.zwa.Level or 0
    ply.zwa.Money = ply.zwa.Money or 0
    ply.zwa.EXP = ply.zwa.EXP or 0
	ply.zwa.ReqExp = ply.zwa.ReqExp or 2500

    --Inventory
    ply.zwa.Inventory = ply.zwa.Inventory or {}
    ply.zwa.Inventory.SlotInfo = ply.zwa.Inventory.SlotInfo or {}
    ply.zwa.Inventory.MaxSlots = ply.zwa.Inventory.MaxSlots or 24

    --Skills
    ply.zwa.Skills = ply.zwa.Skills or {}
	ply.zwa.SkillPoints = ply.zwa.SkillPoints or 0

	--Statuses
	ply.zwa.LastHealth = ply.zwa.LastHealth or 100
	ply.zwa.Hunger = ply.zwa.Hunger or 100
	ply.zwa.Thirst = ply.zwa.Thirst or 100
	ply.zwa.Infection = ply.zwa.Infection or 0

	--Effects are an active effect like bleeding or radiation
	ply.zwa.Effects = ply.zwa.Effects or {}

    ply:UpdateNetwork()
end

local function LoadData(ply)
	local PlayerID = string.Replace(ply:SteamID(), ":", "!")
	local jsonContent = file.Read("zwa_data/" .. PlayerID .. ".txt", "DATA")
	if not jsonContent then return false end

	-- Read persistent data from JSON
	ply.zwa = util.JSONToTable(jsonContent)

	-- Init not set fields of persistent data
	InitData(ply)
	
	-- Init player model and other stuff
	ply:SetModel(ply.zwa.Model)
	
	return true -- Return true to signal that the settings could be loaded
end

local function SavePlayerData(ply)
	local PlayerID = string.Replace(ply:SteamID(), ":", "!")

	-- Store all persistent data as JSON
	file.Write("zwa_data/" .. PlayerID .. ".txt", util.TableToJSON(ply.zwa, true))
end

--If there isn't a zwa data folder, create one
hook.Add("Initialize", "CreateDataFolder", function()
	//if GAMEMODE.MYSQL.Data.Type ~= "txt" then return end
	
	if not file.IsDir( "zwa_data", "DATA") then
		MsgC(Color(255, 0, 0), "MISSING ZW:A FOLDER: Making new one\n")
		file.CreateDir("zwa_data", "DATA")
	end
end)

--When the player disconnects, save their data
hook.Add("PlayerDisconnected", "ZWA_SavePlayerDataDisconnect", function(ply) 
	SavePlayerData(ply)
end)


--Upon a map change or server shutdown, save everyones progress
hook.Add( "ShutDown", "zwa_MapChangeSave", function()
	--If we aren't using TXT format saving, stop here
	//if GAMEMODE.MYSQL.Data.Type ~= "txt" then return end

	for _, v in ipairs( player.GetAll() ) do
		SavePlayerData(v)
	end
end)


hook.Add("PlayerInitialSpawn", "ZWA_NewPlayerCheck", function(ply)
	--If the player is a bot, set model to kleiner and stop there
	if ply:IsBot() then
		ply:SetModel("models/player/kleiner.mdl")
		return
	end

	//if GAMEMODE.MYSQL.Data.Type ~= "txt" then return end

	--If its a new player, create a save file for saving (and ensuring the player isn't a bot)
	if !LoadData(ply) and !ply:IsBot() then
		InitData(ply)
		return
	end
	
	--If its a returning player, load their save file
	LoadData(ply)
end)
