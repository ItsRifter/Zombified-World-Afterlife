local staminaRate = 0.25
local staminaRegen = 0.05
local staminaDelay = 7

function PlayerSpawn(ply)
    ply.spawnProtection = 10 + CurTime()
    ply.playerStamina = 100
    ply.lastSprint = 0

    ply:SetNWInt("ZWR_Stat_Stamina", ply.playerStamina)
end

hook.Add("PlayerInitialSpawn", "ZWR_PlayerInitialSpawn", function(ply, transition)
    PlayerSpawn(ply)
end)

hook.Add("PlayerSpawn", "ZWR_PlayerRespawn", function(ply, transition)
    PlayerSpawn(ply)
end)

--Spawn protection cooldown
hook.Add("Think", "ZWR_SPTimer", function()

end)

hook.Add("PlayerDeath", "ZWR_PlayerDeath", function(victim, inflictor, attacker)

end)

hook.Add("PlayerSwitchFlashlight", "ZWR_AllowFlashlight", function(ply, boolean)
    return true
end)

hook.Add("PlayerPostThink", "ZWR_PlayerPostThink", function(ply)
    --Regens stamina
    if ply.lastSprint < CurTime() and ply.playerStamina < 100 then
        ply.playerStamina = math.Clamp(ply.playerStamina + staminaRegen, 1, 100)
        ply:SetNWInt("ZWR_Stat_Stamina", math.Round(ply.playerStamina))
    end

    --IF we're moving, not crouching and sprinting with stamina above 0, start sprinting
    if ply:KeyDown( IN_FORWARD ) and not ply:KeyDown(IN_DUCK) and ply:KeyDown( IN_SPEED ) and ply.playerStamina > 0 then
        ply.lastSprint = staminaDelay + CurTime()
        ply.playerStamina = ply.playerStamina - staminaRate
        ply:SetNWInt("ZWR_Stat_Stamina", math.Round(ply.playerStamina))
    end

end)

--Handles Movemennt
hook.Add("Move", "ZWR_Movement", function(ply, mv)

    mv:SetMaxSpeed( 150 )
    mv:SetMaxClientSpeed( 150 )

    --If sprinting and stamina is sufficent, increase the speed 
    if ply:KeyDown( IN_SPEED ) and not ply:KeyDown(IN_DUCK) and ply:KeyDown( IN_FORWARD ) and ply.playerStamina > 0 then       
        local speed = mv:GetMaxSpeed() * 1.65
        mv:SetMaxSpeed( speed )
        mv:SetMaxClientSpeed( speed )

    end

    --Don't return true, we don't want to overwrite the engine
	return false

end)