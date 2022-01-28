--Taken from The Commanders 'Underdone' gamemode
--DON'T BLAME ME, BLAME THE INTERNET FOR LACKING TUTORIALS

SaveSystem = {}
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

function SaveSystem:Initialize()
	self.m_intSnapshotInterval = GAMEMODE.MYSQL.Data.MySQLSnapshotInterval
	local plyMeta = debug.getregistry().Player
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
			self.ZWR.ReqEXP = self.ZWR.ReqEXP or 2500

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

			self:SetModel("models/player/Group01/male_07.mdl")

			InventoryGiveItem(self, "zwr_weapon_crowbar")
            InventoryGiveItem(self, "zwr_weapon_glock")
            AddCash(self, 2500)

			self:SetNWInt( "ZWR_XP", self.ZWR.EXP )
			self:SetNWInt( "ZWR_SkillPoints", self.ZWR.SkillPoints )
			self:SetModel( self.ZWR.Model )
			self:SetUpHands(self)
		end)
	end

	function plyMeta:LoadSave()
		if self.m_bLoadingGameData then print("fail") return end
		self.m_bLoadingGameData = true

		SaveSystem:LoadPlayerData( self, function( bErr, tblData )
			if bErr then
				if IsValid( self ) then self:Kick( "There was an issue loading your player data, please try rejoining." ) end
				SaveSystem:Error( "Fatal Error! LoadPlayerData dropping client from game." )
				return
			elseif not IsValid( self ) then
				return
			end
			self.m_bLoadingGameData = false
			self.Data = tblData
			PrintTable(self.Data)
			--Apply data from MYSQL to the player
			self:SetPlayerSQLID( tblData.ID )
			self:SetNWInt( "ZWR_XP", tblData.Exp or 0 )
			self:SetNWInt( "ZWR_SkillPoints", self:GetDeservedSkillPoints() )
			self:SetModel( tblData.Model or "models/player/Group01/male_07.mdl" )
            
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

			self.Loaded = true
			self:SetNWBool( "Loaded", true )

			if tblData.NewPlayer then
				self:NewSave()
			end
			
		end )
		
		return true
	end

	function plyMeta:SaveFile( strDiffFlag, strSubFlag )
		SaveSystem:MarkDiffDirty( self, strDiffFlag, strSubFlag )
	end

	function plyMeta:CommitSaveFile( funcSaved )
		if not self.Loaded or not self.Data then return false end
		if self.m_bInSave then return false end
		self.m_bInSave = true
		SaveSystem:CommitPlayerDiffs( self:SteamID64(), function( bErr )
			if not IsValid( self ) then return end
			self.m_bInSave = false
			if funcSaved then funcSaved() end
		end )
		return true
	end

	function plyMeta:IsDoingSave()
		return self.m_bInSave
	end

	hook.Add( "Tick", "ZWReborn_MySQLUpdate", function()
		for _, v in pairs( player.GetAll() ) do
			self:TickPlayer( v )
		end
	end )
	hook.Add( "ShutDown", "ZWReborn_MySQLUpdate", function()
		for _, v in pairs( player.GetAll() ) do
			self:PlayerDisconnected( v:SteamID64() )
		end
	end )
	hook.Add( "PlayerDisconnected", "ZWReborn_MySQLUpdate", function( pl )
		self:PlayerDisconnected( pl:SteamID64() )
	end )

    gameevent.Listen( "player_disconnect" )
	hook.Add( "player_disconnect", "ZWReborn_MySQLUpdate", function( tblData )
		self:PlayerDisconnected( util.SteamIDTo64(tblData.networkid) )
	end )

	self:Connect(
		GAMEMODE.MYSQL.Data.Host,
		GAMEMODE.MYSQL.Data.Username,
		GAMEMODE.MYSQL.Data.Password,
		GAMEMODE.MYSQL.Data.Database,
		GAMEMODE.MYSQL.Data.Port
	)
	RunConsoleCommand( "sv_hibernate_think", "1" )
end

-- MySQL functions
-- ----------------------------------------------------------------
function SaveSystem:Msg( str )
	print( "[ZWR:MySQL] ".. str )
end

function SaveSystem:Error( str )
	error( "[ZWR:MySQL] ".. str.. "\n" )
end

function SaveSystem:ErrorNoHalt( str )
	ErrorNoHalt( "[ZWR:MySQL] ".. str.. "\n" )
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

	self:Msg( "Connecting to database..." )
	self.m_pDB:connect()
end

function SaveSystem:OnDatabaseConnected( pDB )
	self:Msg( "Successfully connected to the database" )
	self:InitTables()
end

function SaveSystem:OnDatabaseConnectionFailed( pDB, strErr )
	self:Msg( "Fatal Error! Connection to database failed! MySQL said: ".. strErr )
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



-- Player save/load functionality
-- ----------------------------------------------------------------
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
		`exp` INT UNSIGNED NOT NULL DEFAULT 0,
		`setup` INT NOT NULL DEFAULT 0,
		`lasthealth` INT UNSIGNED NOT NULL DEFAULT 100,
		`lastseen` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
		PRIMARY KEY (`id`),
		UNIQUE INDEX `zwr_id_steamid` (`id`, `steamid`),
		INDEX `steamid` (`steamid`)
	) ENGINE=InnoDB;]],
}

local plMeta = debug.getregistry().Player
function plMeta:GetPlayerSQLID()
	return self.m_intSQLID
end

function plMeta:SetPlayerSQLID( intID )
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
		lasthealth=%d,
		lastseen=FROM_UNIXTIME(%d)]]
	):format(
		pl:SteamID64(),
		self:Escape( pl:GetName() ),
		self:Escape( pl:GetModel() ),
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
		dataProto.Level = tblData.level
		dataProto.Exp = tblData.exp
		dataProto.Model = tblData.model or "models/player/Group01/male_07.mdl"
		dataProto.NewPlayer = bAutoInsertCallback and true
		
		pl:SetModel(dataProto.Model)

		if not dataProto.NewPlayer and (not tblData.setup or tblData.setup ~= 1) then
			pl:NewSave()
		end

		--Load all save tables, then call callback
		local done, count = 0, table.Count( self.m_tblSaveTables )
		for _, v in pairs( self.m_tblSaveTables ) do
			v.QueryFunc( dataProto.ID, function( b, data )
				done = done +1
				
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
	self.m_tblSaveTables[#self.m_tblSaveTables +1] = tblData
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
		self:ErrorNoHalt( "transaction error!", strErr )
		if fnCallback then fnCallback( false ) end
	end

	gameData.m_bInSQLUpdate = true
	transaction:start()
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