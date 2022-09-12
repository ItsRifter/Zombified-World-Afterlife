local ZWA_Player = FindMetaTable("Player")

local snd_hurt_male = {
	[1] = "vo/npc/male01/pain01.wav",
	[2] = "vo/npc/male01/pain02.wav",
	[3] = "vo/npc/male01/pain03.wav",
	[4] = "vo/npc/male01/pain04.wav",
	[5] = "vo/npc/male01/pain05.wav",
    [6] = "vo/npc/male01/pain06.wav",
    [7] = "vo/npc/male01/pain07.wav",
    [8] = "vo/npc/male01/pain08.wav",
    [9] = "vo/npc/male01/pain09.wav",
}

local snd_hurt_female = {
	[1] = "vo/npc/female01/pain01.wav",
	[2] = "vo/npc/female01/pain02.wav",
	[3] = "vo/npc/female01/pain03.wav",
	[4] = "vo/npc/female01/pain04.wav",
	[5] = "vo/npc/female01/pain05.wav",
    [6] = "vo/npc/female01/pain06.wav",
    [7] = "vo/npc/female01/pain07.wav",
    [8] = "vo/npc/female01/pain08.wav",
    [9] = "vo/npc/female01/pain09.wav",
}

function ZWA_Player:SetUp()
    self:SetModel(self.zwa.Model)
    self:SetupHands()

    self.lastSprint = 0
    self.lastFlash = 0
    self.respawnTime = 0

    self.stamina = 100
    self.flashBattery = 100
    self.bounty = self.bounty or 0

    self.spawnProtection = GetConVar("zwa_time_spawnprotection"):GetInt() + CurTime()
end


function ZWA_Player:InitialSpawn()
    self:SetUp()
    self:UpdateNetwork()
end

function ZWA_Player:FirstTime()
    
end

function ZWA_Player:SendMessage(...)
    net.Start("ZWA_PlayerMessage")
        net.WriteTable({...})
    net.Send(self)
end

function ZWA_Player:BroadcastSound(sndFile)
    net.Start("ZWA_PlayerMsgSound")
        net.WriteString(sndFile)
    net.Send(self)
end

function ZWA_Player:Respawn()
    self:SetUp()
    self:UpdateNetwork()
end

function ZWA_Player:AddInventoryItem(itemKey)

end

function ZWA_Player:RemoveInventroyItem(itemKey)

end

function ZWA_Player:SetInventory(invTbl)
    self.zwa.Inventory.SlotInfo = invTbl
end

function ZWA_Player:UpdateNetwork()
    self:SetNWInt("zwa.pl.xp", self.zwa.EXP)
    self:SetNWInt("zwa.pl.reqxp", self.zwa.ReqEXP)
    self:SetNWInt("zwa.pl.money", self.zwa.Money)
    self:SetNWInt("zwa.pl.level", self.zwa.Level)

    self:SetNWInt("zwa.pl.status.hunger", self.zwa.Hunger)
    self:SetNWInt("zwa.pl.status.thirst", self.zwa.Thirst)
    self:SetNWInt("zwa.pl.status.infection", self.zwa.Infection)

    self:SetNWInt("zwa.pl.stamina", self.stamina or 100)
    self:SetNWInt("zwa.pl.flashlight", self.flashBattery or 100)
end

function GM:PlayerHurt(victim, attacker, healthRemaining, damageTaken)
    --If the player has spawn protection, restore health to max
    if victim.spawnProtection and victim.spawnProtection > CurTime() then 
        victim:SetHealth(victim:GetMaxHealth())
        return
    end
    
    --Play hurt sounds
    if string.find(victim:GetModel(), "male") then
        victim:EmitSound(snd_hurt_male[math.random(1, #snd_hurt_male)])
    elseif string.find(victim:GetModel(), "female") then
        victim:EmitSound(snd_hurt_female[math.random(1, #snd_hurt_female)])
    end
end

function ZWA_Player:StatusThink()
    --Regens stamina
    if self.lastSprint and self.lastSprint < CurTime() and self.stamina < 100 then
        self.stamina = math.Clamp(self.stamina + GetConVar("zwa_player_staminaregen"):GetFloat(), 1, 100)
        self:SetNWInt("zwa.pl.stamina", math.Round(self.stamina))
    end

    --If we're moving forward, not crouching and sprinting with stamina above 0, start sprinting
    if self:KeyDown( IN_FORWARD ) and not self:KeyDown(IN_DUCK) and self:KeyDown( IN_SPEED ) and self.stamina > 0 and self:GetMoveType() ~= MOVETYPE_NOCLIP then
        //Check if we're going fast enough to deplete stamina
        if self:GetVelocity():LengthSqr() <= 4000 then return end

        self.lastSprint = 5 + CurTime()
        self.stamina = self.stamina - GetConVar("zwa_player_staminarate"):GetFloat()
        self:SetNWInt("zwa.pl.stamina", math.Round(self.stamina))
    end

    if self.flashBattery <= 0 and self:FlashlightIsOn() then
        self:Flashlight(false)
    elseif self.flashBattery < 25 and !self:FlashlightIsOn() then
        self:AllowFlashlight( false )
    else
        self:AllowFlashlight( true )
    end

    if self:FlashlightIsOn() and self.flashBattery > 0 then
        self.lastFlash = 5 + CurTime()
        self.flashBattery = self.flashBattery - GetConVar("zwa_player_flashrate"):GetFloat()
        self:SetNWInt("zwa.pl.flashlight", self.flashBattery)

    elseif not self:FlashlightIsOn() and self.flashBattery < 100 and self.lastFlash <= CurTime() then
        self.flashBattery = math.Clamp(self.flashBattery + GetConVar("zwa_player_flashregen"):GetFloat(), 0, 100)

        self:SetNWInt("zwa.pl.flashlight", self.flashBattery)
    end
end

hook.Add("PlayerPostThink", "ZWA_PlayerPostThink", function(ply)
    ply:StatusThink()
end)

function ZWA_Player:HandleMovement(mvData)
    mvData:SetMaxClientSpeed( 150 )

    --If sprinting and stamina is sufficent, increase the speed 
    if self:KeyDown( IN_SPEED ) and !self:KeyDown( IN_DUCK ) and self:KeyDown( IN_FORWARD ) and self.stamina > 0 then       
        local speed = mvData:GetMaxSpeed() * 1.65
        mvData:SetMaxClientSpeed( speed )
    end

    --If Crouching, reduce speed
    if self:KeyDown( IN_DUCK ) then
        local speed = mvData:GetMaxSpeed() / 1.65
        mvData:SetMaxClientSpeed( speed )
    end	
end

hook.Add("Move", "ZWA_Player_Movement", function(ply, mv)
    ply:HandleMovement(mv)
end)

function GM:PostPlayerDeath( ply )
    ply:CreateRagdoll()
end

function GM:PlayerInitialSpawn( player, transition )
    player:InitialSpawn()
end

function GM:PlayerSpawn( player, transition )
    player:Respawn()
end