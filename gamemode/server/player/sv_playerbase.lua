--Stamina
local staminaRate = 0.25
local staminaRegen = 0.05
local staminaDelay = 7

--Respawn
local respawnDelay = 10

--Flashlight
local flashRate = 0.05
local flashRegen = 0.025
local flashDelay = 5

function PlayerSpawn(ply)
    ply.spawnProtection = 10 + CurTime()
    
    ply.lastSprint = 0
    ply.lastFlash = 0
    ply.respawnTime = 0

    ply.playerStamina = 100
    ply.flashBattery = 100
    ply.curBounty = ply.curBounty or 0

    --Network statuses
    ply:SetNWInt("ZWR_Stat_Stamina", ply.playerStamina)
    ply:SetNWInt("ZWR_Stat_FlashlightBattery", ply.flashBattery)

    --Network Time
    ply:SetNWInt("ZWR_Time", server_cycleTime)
    ply:SetNWBool("ZWR_Time_IsInvasion", server_isNightTime)

    --Network the statistics if its a player
    if ply.ZWR then
        ply:SetModel(ply.ZWR.Model)

        ply:SetNWInt("ZWR_Level", ply.ZWR.Level)
        ply:SetNWInt("ZWR_XP", ply.ZWR.EXP)
        ply:SetNWInt("ZWR_ReqXP", ply.ZWR.ReqEXP)
        ply:SetNWInt("ZWR_SkillPoints", ply.ZWR.SkillPoints)

        ply:SetNWInt("ZWR_Cash", ply.ZWR.Money)
        ply:SetNWInt("ZWR_Bounty", ply.curBounty)
    end

end

hook.Add("PlayerInitialSpawn", "ZWR_PlayerInitialSpawn", function(ply, transition)
    PlayerSpawn(ply)
end)

hook.Add("PlayerSpawn", "ZWR_PlayerRespawn", function(ply, transition)
    PlayerSpawn(ply)
end)

function GM:PlayerShouldTakeDamage( ply, attacker )
    if attacker:IsPlayer() then
        if ply:GetNWString("ZWR_Faction", Loner) == attacker:GetNWString("ZWR_Faction", Loner) then
            return false
        end
    end

    return true
end

function GM:PlayerHurt(victim, attacker, healthRemaining, damageTaken)
    
    --If the player has spawn protection, restore health to max
    if victim.spawnProtection > CurTime() then 
        victim:SetHealth(victim:GetMaxHealth())
        return
    end
    
    --Play hurt sounds
    if string.find(victim:GetModel(), "male") then
        victim:EmitSound(SOUNDS_MALE_HURT[math.random(1, #SOUNDS_MALE_HURT)])
    elseif string.find(victim:GetModel(), "female") then
        victim:EmitSound(SOUNDS_FEMALE_HURT[math.random(1, #SOUNDS_FEMALE_HURT)])
    end
end

function GM:PlayerDeathThink( ply )
    --After a set time has passed, respawn the player
    if ply.respawnTime < CurTime() then
        ply:Spawn()
    end

    --Don't allow default respawning by the player (Mouse 1: Respawn)
    return false
end

function GM:PlayerCanPickupItem( ply, item )
    return false
end

function GM:PlayerCanPickupWeapon( ply, weapon )
    return true
end

function BroadcastSound(soundFile, targetPlayer)
    net.Start("ZWR_BroadcastSound")
    net.WriteString(soundFile)

    if targetPlayer then
        net.Send(targetPlayer)
    else
        net.Broadcast()
    end
end


function GM:PlayerDeath(victim, inflictor, attacker)
    --On death, set their respawn time and divide bounty
    victim.respawnTime = respawnDelay + CurTime()
    victim.curBounty = victim.curBounty / 2

    --Dying sound
    if string.find(victim:GetModel(), "male") then
        victim:EmitSound(SOUNDS_MALE_HURT[math.random(1, #SOUNDS_MALE_HURT)])
    elseif string.find(victim:GetModel(), "female") then
        victim:EmitSound(SOUNDS_FEMALE_HURT[math.random(1, #SOUNDS_FEMALE_HURT)])
    end
end

--TODO: Battery life for flashlight + Regen
hook.Add("PlayerSwitchFlashlight", "ZWR_AllowFlashlight", function(ply, boolean)
    return true
end)

hook.Add("PlayerPostThink", "ZWR_PlayerPostThink", function(ply)
    --Regens stamina
    if ply.lastSprint < CurTime() and ply.playerStamina < 100 then
        ply.playerStamina = math.Clamp(ply.playerStamina + staminaRegen, 1, 100)
        ply:SetNWInt("ZWR_Stat_Stamina", math.Round(ply.playerStamina))
    end

    --If we're moving, not crouching and sprinting with stamina above 0, start sprinting
    if ply:KeyDown( IN_FORWARD ) and not ply:KeyDown(IN_DUCK) and ply:KeyDown( IN_SPEED ) and ply.playerStamina > 0 then
        ply.lastSprint = staminaDelay + CurTime()
        ply.playerStamina = ply.playerStamina - staminaRate
        ply:SetNWInt("ZWR_Stat_Stamina", math.Round(ply.playerStamina))
    end

    if ply:FlashlightIsOn() and ply.flashBattery > 0 then
        ply.lastFlash = flashDelay + CurTime()
        ply.flashBattery = ply.flashBattery - flashRate
        ply:SetNWInt("ZWR_Stat_FlashlightBattery", ply.flashBattery)

        if ply.flashBattery <= 0 then
            ply:Flashlight( false )
            ply:AllowFlashlight( false )
        end

    elseif not ply:FlashlightIsOn() and ply.flashBattery < 100 and ply.lastFlash <= CurTime() then
        
        ply.flashBattery = math.Clamp(ply.flashBattery + flashRegen, 0, 100)

        ply:SetNWInt("ZWR_Stat_FlashlightBattery", ply.flashBattery)

        if ply.flashBattery > 0 then
            ply:AllowFlashlight( true )
        end
    end
end)

--Handles Movement
hook.Add("Move", "ZWR_Movement", function(ply, mv)

    mv:SetMaxClientSpeed( 150 )

    --If sprinting and stamina is sufficent, increase the speed 
    if ply:KeyDown( IN_SPEED ) and not ply:KeyDown( IN_DUCK ) and ply:KeyDown( IN_FORWARD ) and ply.playerStamina > 0 then       
        local speed = mv:GetMaxSpeed() * 1.65
        mv:SetMaxClientSpeed( speed )
    end

    --If Crouching, reduce speed
    if ply:KeyDown( IN_DUCK ) then
        local speed = mv:GetMaxSpeed() / 1.65
        mv:SetMaxClientSpeed( speed )
    end	
end)

SOUNDS_MALE_HURT = {
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

SOUNDS_FEMALE_HURT = {
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