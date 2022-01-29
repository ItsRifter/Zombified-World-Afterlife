--Taken from The Commanders 'Underdone' gamemode
--DON'T BLAME ME, BLAME THE INTERNET FOR LACKING TUTORIALS

--KEEP IN MIND:
--Lua refreshes WILL muck up the saving so a restart or use of zwr_fixsave is required!

SaveSystem = {}
SaveSystem.m_tblDiffFlags = {}
SaveSystem.m_tblSaveTables = {}
SaveSystem.m_tblPlayerData = {}
SaveSystem.m_tblRunInit = {
	--Root players table
	[[CREATE TABLE IF NOT EXISTS `zwr_players` (
		`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
		`steamid` VARCHAR(255) NOT NULL,
		`name` VARCHAR(25) NOT NULL,
		`model` TEXT NOT NULL,
		`Exp` INT UNSIGNED NOT NULL DEFAULT 0,
		`ReqExp` INT UNSIGNED NOT NULL DEFAULT 0,
		`SkillPoints` INT UNSIGNED NOT NULL DEFAULT 0,
		`Level` INT UNSIGNED NOT NULL DEFAULT 0,
		`lasthealth` INT UNSIGNED NOT NULL DEFAULT 100,
		`lastseen` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		PRIMARY KEY (`id`),
		UNIQUE INDEX `zwr_id_steamid` (`id`, `steamid`),
		INDEX `steamid` (`steamid`)
	) ENGINE=InnoDB;]],
}

local plyMeta = FindMetaTable("Player")

local enc, dec
do
	-- Lua 5.1+ base64 v3.0 (c) 2009 by Alex Kloss <alexthkloss@web.de> 67153048
	-- licensed under the terms of the LGPL2
	-- character table string
	local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	-- encoding
	enc = function(data)
	    return ((data:gsub('.', function(x) 
	        local r,b='',x:byte()
	        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
	        return r;
	    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
	        if (#x < 6) then return '' end
	        local c=0
	        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
	        return b:sub(c+1,c+1)
	    end)..({ '', '==', '=' })[#data%3+1])
	end
	-- decoding
	dec = function(data)
	    data = string.gsub(data, '[^'..b..'=]', '')
	    return (data:gsub('.', function(x)
	        if (x == '=') then return '' end
	        local r,f='',(b:find(x)-1)
	        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
	        return r;
	    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
	        if (#x ~= 8) then return '' end
	        local c=0
	        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
	        return string.char(c)
	    end))
	end
end

function SaveSystem:RegisterDiffFlag( strFlagID, funcUpdate )
	self.m_tblDiffFlags[strFlagID] = funcUpdate
end

function SaveSystem:ClearPlayerDiffTable( strSID64 )
	if not self.m_tblPlayerData[strSID64] then return end
	self.m_tblPlayerData[strSID64].SQLDiffTable = {
		Flags = {},
		NextSnapshot = CurTime() +(self.m_intSnapshotInterval or 60)
	}
end

function SaveSystem:MarkDiffDirty( pl, strFlagID, strSubFlag )
	local data = self.m_tblPlayerData[pl:SteamID64()]
	if not data or not data.SQLDiffTable then return end
	if not self.m_tblDiffFlags[strFlagID] then return end

	if strSubFlag then
		data.SQLDiffTable.Flags[strFlagID] = data.SQLDiffTable.Flags[strFlagID] or {}
		data.SQLDiffTable.Flags[strFlagID][strSubFlag] = true
	else
		data.SQLDiffTable.Flags[strFlagID] = true
	end
end

function SaveSystem:GetPlayerDiffFlags( pl )
	if not self.m_tblPlayerData[pl:SteamID64()] or not self.m_tblPlayerData[pl:SteamID64()].SQLDiffTable then return {} end
	return self.m_tblPlayerData[pl:SteamID64()].SQLDiffTable.Flags or {}
end

function SaveSystem:TickPlayer( pl )
	if GAMEMODE.StopSaving then return end
	local data = self.m_tblPlayerData[pl:SteamID64()]
	if not data or not data.SQLDiffTable or not data.SQLDiffTable.Flags then return end
	if data.SQLDiffTable.NextSnapshot >= CurTime() then return end
	self:CommitPlayerDiffs( pl:SteamID64() )
end

function SaveSystem:PlayerDisconnected( strSID64 )
	self:CommitPlayerDiffs( strSID64, function()
		self.m_tblSaveTables[strSID64] = nil
	end )
end

function SaveSystem:Initialize()
	self.m_intSnapshotInterval = GAMEMODE.MYSQL.Data.MySQLSnapshotInterval
	if game.SinglePlayer() then
		g_OldSID = g_OldSID or plyMeta.SteamID
		function plyMeta:SteamID()
			return "singleplayer"
		end
		g_OldSID64 = g_OldSID64 or plyMeta.SteamID64
		function plyMeta:SteamID64()
			return "singleplayer"
		end
	end

	self:Connect(
		GAMEMODE.MYSQL.Data.Host,
		GAMEMODE.MYSQL.Data.Username,
		GAMEMODE.MYSQL.Data.Password,
		GAMEMODE.MYSQL.Data.Database,
		GAMEMODE.MYSQL.Data.Port
	)
end

function plyMeta:NewSave()
	timer.Simple(1, function()
		self.ZWR = self.ZWR or {}

		--Basics
		self.ZWR.Name = self.ZWR.Name or self:Nick()
		self.ZWR.Model = self.ZWR.Model or "models/player/Group01/male_07.mdl"
		
		--Leveling etc.
		self.ZWR.Level = self.ZWR.Level or 0
		self.ZWR.Money = self.ZWR.Money or 0
		self.ZWR.EXP = self.ZWR.EXP or 0
		self.ZWR.ReqExp = self.ZWR.ReqExp or 2500

		--Inventory
		self.ZWR.Inventory = self.ZWR.Inventory or {}
		self.ZWR.InvMaxSlotsWidth = self.ZWR.InvMaxSlotsWidth or 5
		self.ZWR.InvMaxSlotsHeight = self.ZWR.InvMaxSlotsHeight or 6

		--Skills
		self.ZWR.Skills = self.ZWR.Skills or {}
		self.ZWR.SkillPoints = self.ZWR.SkillPoints or 0

		--Statuses
		self.ZWR.LastHealth = self.ZWR.LastHealth or 100
		self.ZWR.Hunger = self.ZWR.Hunger or 100
		self.ZWR.Thirst = self.ZWR.Thirst or 100
		self.ZWR.Infection = self.ZWR.Infection or 0
		--Effects is an active effect like bleeding or radiation
		self.ZWR.Effects = self.ZWR.Effects or {}
	end)
end

function plyMeta:LoadSave()
	SaveSystem:LoadPlayerData( self, function( bErr, tblData )
		if bErr then
			if IsValid( self ) then self:Kick( "There was an issue loading your player data, please try rejoining." ) end
			SaveSystem:Error( "Fatal Error! LoadPlayerData dropping client from game." )
			return
		elseif not IsValid( self ) then
			return
		end

		self.ZWR = tblData

		if tblData.NewPlayer then
			print("New player")
			self:NewSave()
			NewPlayerInventory(self)
		end
		
		--Apply data from MYSQL to the player
		self:SetPlayerSQLID( tblData.ID )
		self:SetNWInt( "ZWR_XP", self.ZWR.EXP )
		self:SetNWInt( "ZWR_SkillPoints", self.ZWR.SkillPoints )
		
		--We want to update this data every time we setup this player
		tblData.Name = self:GetName()
		tblData.LastSeen = os.time()
		SaveSystem:MarkDiffDirty( self, "LastSeen" )
		SaveSystem:MarkDiffDirty( self, "Name" )
		
		--Apply data from all save tables to the player
		--This function must follow the correct load order (The order DefineSaveTable is called in)
		for _, v in ipairs( SaveSystem:GetSaveTable() ) do
			if tblData.SaveTables[v.LuaName] then
				v.LoadFunc( self, tblData.SaveTables[v.LuaName] )
			end
		end
	end)
end

function plyMeta:SaveFile( strDiffFlag, strSubFlag )
	SaveSystem:MarkDiffDirty( self, strDiffFlag, strSubFlag )
end

function plyMeta:CommitSaveFile()
	if self.InSave then return false end
	self.InSave = true

	SaveSystem:CommitPlayerDiffs( self:SteamID64(), function( bErr )
		if not IsValid( self ) then return end
		self.InSave = false
	end )

	return true
end

function plyMeta:IsDoingSave()
	return self.InSave
end

hook.Add( "Tick", "ZWReborn_MySQLUpdate", function()
	for _, v in pairs( player.GetAll() ) do
		SaveSystem:TickPlayer( v )
	end
end )
hook.Add( "ShutDown", "ZWReborn_MySQLUpdate", function()
	for _, v in pairs( player.GetAll() ) do
		SaveSystem:PlayerDisconnected( v:SteamID64() )
	end
end )
hook.Add( "PlayerDisconnected", "ZWReborn_MySQLUpdate", function( pl )
	SaveSystem:PlayerDisconnected( pl:SteamID64() )
end )

gameevent.Listen( "player_disconnect" )
hook.Add( "player_disconnect", "ZWReborn_MySQLUpdate", function( tblData )
	SaveSystem:PlayerDisconnected( util.SteamIDTo64(tblData.networkid) )
end )

RunConsoleCommand( "sv_hibernate_think", "1" )

-- MySQL functions
-- ----------------------------------------------------------------
function SaveSystem:Message( str )
	print( "[ZWR:MySQL] " .. str )
end

function SaveSystem:Error( str )
	error( "[ZWR:MySQL] " .. str .. "\n" )
end

function SaveSystem:ErrorNoHalt( str )
	ErrorNoHalt( "[ZWR:MySQL] " .. str.. "\n" )
end
	
function SaveSystem:Connect( strHost, strUser, strPass, strDBName, intPort, ... )
	pcall( require, "mysqloo" )
	if not mysqloo then
		self:Error( "Fatal Error! Unable to load gmsv_mysqloo SaveSystem!" )
		return
	end

	self.m_pDB = mysqloo.connect( strHost, strUser, strPass, strDBName, intPort, ... )
	self.m_pDB.onConnected = function( pDB )
		self:OnDatabaseConnected( pDB )

		if self.m_tblQueryBuffer then
			for i = 1, #self.m_tblQueryBuffer do
				self:Query( self.m_tblQueryBuffer[i][1], self.m_tblQueryBuffer[i][2] )
			end
			self.m_tblQueryBuffer = nil
		end
	end
	self.m_pDB.onConnectionFailed = function( pDB, strErr )
		self:OnDatabaseConnectionFailed( pDB, strErr )
	end

	self:Message( "Connecting to database..." )
	self.m_pDB:connect()
end

function SaveSystem:OnDatabaseConnected( pDB )
	self:Message( "Successfully connected to the database" )
	self:InitTables()
end

function SaveSystem:OnDatabaseConnectionFailed( pDB, strErr )
	self:Message("Fatal Error! Connection to database failed! MySQL said: ".. strErr)
	self:Message("Reverting to flatfile")
	GAMEMODE.MYSQL.Data.Type = "txt"
end

function SaveSystem:Escape( str )
	return self.m_pDB and self.m_pDB:escape( str ) or SQLStr( str, true )
end

function SaveSystem:GetDatabase()
	return self.m_pDB
end

function SaveSystem:Query( strQuery, fnCallback )
	if not self.m_pDB then
		self.m_tblQueryBuffer = self.m_tblQueryBuffer or {}
		self.m_tblQueryBuffer[#self.m_tblQueryBuffer+1] = { strQuery, fnCallback }
		return
	end

	local q = self.m_pDB:query( strQuery )
	q.onSuccess = function( q, data )
		if fnCallback then fnCallback( false, data ) end
	end
	q.onError = function( q, err )
		if fnCallback then fnCallback( true, err ) end
	end
	q.onAbort = function( q )
	end
	q.onData = function( q, data )
	end

	q:start()
end

function plyMeta:GetPlayerSQLID()
	return self.m_intSQLID
end

function plyMeta:SetPlayerSQLID( intID )
	self.m_intSQLID = tonumber( intID )
end

function SaveSystem:GetSaveTable()
	return self.m_tblSaveTables
end

function SaveSystem:InitTables()
	for _, v in pairs( self.m_tblRunInit ) do
		self:Query( v, function( b, err )
			if b then
				self:Error( err )
			end
		end )
	end
	for _, v in pairs( self.m_tblSaveTables ) do
		self:Query( v.Queries.Init, function( b, err )
			if b then
				self:Error( err )
			end
		end )
	end
end

function SaveSystem:InsertNewPlayer( pl, funcOnInsert )
	self:Query( ([[INSERT INTO zwr_players SET
		steamid='%s',
		name='%s',
		model='%s',
		exp=%d,
		ReqExp=%d,
		SkillPoints=%d,
		level=%d,
		lasthealth=%d,
		lastseen=FROM_UNIXTIME(%d)]]
	):format(
		pl:SteamID64(),
		self:Escape( pl:GetName() ),
		self:Escape( "models/player/Group01/male_07.mdl" ),
		0,
		2500,
		0,
		0,
		100,
		os.time()
	), function( bErr, tblData )
		if not IsValid( pl ) then return end
		funcOnInsert( bErr, tblData )
	end )
end

--Load all data that links back to players `id`
function SaveSystem:LoadPlayerData( pl, fnCallback, bAutoInsertCallback )
	local sid = pl:SteamID64()
	local errors = false
	local dataProto = {
		ID = -1,
		SaveTables = {},
	}
	
	--Load from players
	local playerRowQuery = ([[SELECT * FROM zwr_players WHERE steamid = '%s']]):format( sid )
	self:Query( playerRowQuery, function( bErr, tblData )
		if not IsValid( pl ) then return end
		
		if bErr then
			SaveSystem:ErrorNoHalt( "Fatal Error! LoadPlayerData dropping client from game. MySQL said: ".. tblData )
			pl:Kick( "There was an issue loading your player data, please try rejoining." )
			return
		end

		tblData = tblData[1]

		if not istable( tblData ) or not tblData.id then
			if bAutoInsertCallback then
				SaveSystem:ErrorNoHalt( "Fatal Error! LoadPlayerData dropping client from game. MySQL said: ".. tblData )
				pl:Kick( "There was an issue loading your player data, please try rejoining." )
				return
			end
			
			self:InsertNewPlayer( pl, function( err, data )
				if not IsValid( pl ) then return end
				if not err then
					self:LoadPlayerData( pl, fnCallback, true )
				else
					SaveSystem:ErrorNoHalt( "Fatal Error! LoadPlayerData dropping client from game. MySQL said: ".. data )
					pl:Kick( "There was an issue loading your player data, please try rejoining." )
				end
			end )
			
			return
		end

		dataProto.ID = tblData.id
		dataProto.Sid = pl:SteamID()
		dataProto.LastHealth = tblData.lasthealth or 100
		dataProto.LastSeen = os.time()
		dataProto.Level = tblData.Level
		dataProto.Exp = tblData.Exp
		dataProto.ReqExp = tblData.ReqExp
		dataProto.Model = tblData.model or "models/player/Group01/male_07.mdl"
		dataProto.Skillpoints = tblData.SkillPoints
		dataProto.NewPlayer = bAutoInsertCallback and true
		
		if not dataProto.NewPlayer and (not tblData.setup or tblData.setup ~= 1) then
			pl:NewSave() 
		end

		pl.ZWR = pl.ZWR or {}
		pl.ZWR.Level = dataProto.Level
		pl.ZWR.EXP = dataProto.Exp
		pl.ZWR.ReqExp = dataProto.ReqExp
		pl.ZWR.Model = dataProto.Model
		pl.ZWR.SkillPoints = dataProto.Skillpoints
		
		pl:SetNWInt("ZWR_Inventory_SlotWidth", pl.ZWR.InvMaxSlotsWidth)
		pl:SetNWInt("ZWR_Inventory_SlotHeight", pl.ZWR.InvMaxSlotsHeight)
			
    	pl:SetModel(pl.ZWR.Model)

		pl:SetNWInt("ZWR_Level", pl.ZWR.Level)
        pl:SetNWInt("ZWR_XP", pl.ZWR.EXP)
        pl:SetNWInt("ZWR_ReqXP", pl.ZWR.ReqExp)
        pl:SetNWInt("ZWR_SkillPoints", pl.ZWR.SkillPoints)
        pl:SetNWInt("ZWR_Cash", pl.ZWR.Money)

        for i, f in pairs(CURRENT_FACTIONS) do
            net.Start("ZWR_Faction_Create_Server")
                net.WriteString(f.name)
                net.WriteEntity(f.owner)
                net.WriteBool(f.inviteOnly)
                net.WriteTable(f.curPlayers)
            net.Send(pl)
        end

		--Load all save tables, then callback
		local done, count = 0, table.Count( self.m_tblSaveTables )
		for _, v in pairs( self.m_tblSaveTables ) do
			v.QueryFunc( dataProto.ID, function( b, data )
				done = done + 1
				if not b then
					dataProto.SaveTables[v.LuaName] = data
				else
					errors = true
					self:ErrorNoHalt( "Query Error! LoadPlayerData:".. sid.. ": ".. data )
				end

				if done >= count then
					self.m_tblPlayerData[sid] = dataProto
					self:ClearPlayerDiffTable( sid )
					fnCallback( errors, dataProto )
				end
			end )
		end
	end )
end

function SaveSystem:DefineSaveTable( tblData )
	self.m_tblSaveTables[#self.m_tblSaveTables + 1] = tblData
	self:RegisterDiffFlag( tblData.LuaName, tblData.DiffFunc )
end

function SaveSystem:GetQuery( strLuaName, strQueryK )
	for k, v in pairs( self.m_tblSaveTables ) do
		if v.LuaName == strLuaName then
			return v.Queries[strQueryK]
		end
	end
end

function SaveSystem:CommitPlayerDiffs( strSID64, fnCallback )
	local gameData = self.m_tblPlayerData[strSID64]
	if not gameData or gameData.m_bInSQLUpdate then return end
	
	local playerID = gameData.ID

	if not playerID then return end
	local diffFlags = gameData.SQLDiffTable
	if not diffFlags or not diffFlags.Flags then return end

	local transaction = self.m_pDB:createTransaction()
	for k, v in pairs( diffFlags.Flags ) do
		local ret = self.m_tblDiffFlags[k](playerID, gameData, diffFlags.Flags)
		if istable( ret ) then
			for k, v in ipairs( ret ) do
				transaction:addQuery( self.m_pDB:query(v) )
			end
		else
			transaction:addQuery( self.m_pDB:query(ret) )
		end
	end

	function transaction:onSuccess()
		SaveSystem:ClearPlayerDiffTable( strSID64 )
		gameData.m_bInSQLUpdate = false
		if fnCallback then fnCallback( true ) end
	end
	
	function transaction:onError( strErr )
		gameData.m_bInSQLUpdate = false
		SaveSystem:ErrorNoHalt( "transaction error! " ..strErr )
		if fnCallback then fnCallback( false ) end
	end
	gameData.m_bInSQLUpdate = true
	transaction:start()
end

--Update functions
SaveSystem:RegisterDiffFlag( "LastSeen", function( plyID, plyData, tblDiffFlags )
	return ([[UPDATE zwr_players SET lastseen = FROM_UNIXTIME(%d) WHERE id = %d]]):format( plyData.LastSeen or 0, plyID )
end )

SaveSystem:RegisterDiffFlag( "LastHealth", function( plyID, plyData, tblDiffFlags )
	return ([[UPDATE zwr_players SET lasthealth = %d WHERE id = %d]]):format( plyData.LastHealth or 100, plyID )
end )

SaveSystem:RegisterDiffFlag( "Name", function( plyID, plyData, tblDiffFlags )
	return ([[UPDATE zwr_players SET name = '%s' WHERE id = %d]]):format( SaveSystem:Escape(plyData.Name), plyID )
end )

SaveSystem:RegisterDiffFlag( "Model", function( plyID, plyData, tblDiffFlags )
	return ([[UPDATE zwr_players SET model = '%s' WHERE id = %d]]):format( SaveSystem:Escape(plyData.Model), plyID )
end )

SaveSystem:RegisterDiffFlag( "Level", function( plyID, plyData, tblDiffFlags )
	return ([[UPDATE zwr_players SET Level = %d WHERE id = %d]]):format( plyData.Level, plyID )
end )

SaveSystem:RegisterDiffFlag( "ReqExp", function( plyID, plyData, tblDiffFlags )
	return ([[UPDATE zwr_players SET ReqExp = %d WHERE id = %d]]):format( plyData.ReqExp, plyID )
end )

SaveSystem:RegisterDiffFlag( "EXP", function( plyID, plyData, tblDiffFlags )
	return ([[UPDATE zwr_players SET Exp = %d WHERE id = %d]]):format( plyData.EXP, plyID )
end )

SaveSystem:DefineSaveTable{
	LuaName = "Inventory",
	SQLName = "zwr_inventory",

	Queries = {
		--Init table
		Init = [[CREATE TABLE IF NOT EXISTS `zwr_inventory` (
			`player_id` INT UNSIGNED NOT NULL,
			`item_name` VARCHAR(255) NOT NULL,
			`item_count` INT UNSIGNED NOT NULL,
			FOREIGN KEY (`player_id`) REFERENCES zwr_players(`id`),
			UNIQUE INDEX `zwr_id_item_name` (`player_id`, `item_name`),
			INDEX `player_id` (`player_id`)
		) ENGINE=InnoDB;]],
		--Update query
		Update = [[INSERT INTO zwr_inventory (player_id, item_name, item_count) VALUES (%d, '%s', %d) ON DUPLICATE KEY UPDATE item_count = %d]], 
		--Remove query
		Remove = [[DELETE FROM zwr_inventory WHERE player_id = %d AND item_name = '%s']],
	},

	--DiffFlag function
	DiffFunc = function( intPlayerID, tblPlayerData, tblDiffFlags )
		if not tblDiffFlags["Inventory"] then return end
		if not tblPlayerData.Inventory then return end
	
		local index = 1
		local query = {}

		for itemName, _ in pairs( tblDiffFlags["Inventory"] ) do
			local count = 0
			
			for i, n in pairs(tblPlayerData.Inventory) do
				if n.Name == itemName then
					count = count + 1
				end
			end

			if count <= 0 then
				table.insert( query, SaveSystem:GetQuery( "Inventory", "Remove" ):format( intPlayerID, SaveSystem:Escape(itemName) ) )
			else
				table.insert( query, SaveSystem:GetQuery( "Inventory", "Update" ):format( intPlayerID, SaveSystem:Escape(itemName), count, count ) )
			end
			index = index + 1
		end
		return query
	end,

	--PlayerLoad
	LoadFunc = function( pl, tblData )
		
		InitInventory(pl)
		
		for k, v in pairs( tblData ) do
			InventoryGiveItem(pl, v)
		end
	end,
	--DataLoad
	QueryFunc = function( plyID, fnCallback )
		local q = SaveSystem:GetDatabase():query( ([[SELECT * FROM zwr_inventory WHERE player_id = %d]]):format(plyID) )
		q.onSuccess = function( q, data )
			local ret = {}
			for k, v in pairs( data ) do
				for i = 1, v.item_count do
					table.insert(ret, v.item_name)
				end
			end

			fnCallback( false, ret )
		end
		q.onError = function( q, err )
			fnCallback( true, err  )
		end
		q:start()
	end
}