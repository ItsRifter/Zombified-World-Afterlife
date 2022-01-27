--While not an efficient way of doing the zombies in the VJ official addon but this will do 
ZOMBIE_KILL_REWARDS_BOUNTY = {
    --Basic zombies
    ["npc_vj_zss_zombie1"] = {bMin = 25, bMax = 75},
    ["npc_vj_zss_zombie2"] = {bMin = 25, bMax = 75},
    ["npc_vj_zss_zombie3"] = {bMin = 25, bMax = 75},
    ["npc_vj_zss_zombie4"] = {bMin = 25, bMax = 75},
    ["npc_vj_zss_zombie5"] = {bMin = 25, bMax = 75},
    ["npc_vj_zss_zombie6"] = {bMin = 25, bMax = 75},
    ["npc_vj_zss_zombie7"] = {bMin = 25, bMax = 75},
    ["npc_vj_zss_zombie8"] = {bMin = 25, bMax = 75},
    ["npc_vj_zss_zombie9"] = {bMin = 25, bMax = 75},
}

ZOMBIE_KILL_REWARDS_XP = {
    --Basic zombies
    ["npc_vj_zss_zombie1"] = {xpMin = 15, xpMax = 50},
    ["npc_vj_zss_zombie2"] = {xpMin = 15, xpMax = 50},
    ["npc_vj_zss_zombie3"] = {xpMin = 15, xpMax = 50},
    ["npc_vj_zss_zombie4"] = {xpMin = 15, xpMax = 50},
    ["npc_vj_zss_zombie5"] = {xpMin = 15, xpMax = 50},
    ["npc_vj_zss_zombie6"] = {xpMin = 15, xpMax = 50},
    ["npc_vj_zss_zombie7"] = {xpMin = 15, xpMax = 50},
    ["npc_vj_zss_zombie8"] = {xpMin = 15, xpMax = 50},
    ["npc_vj_zss_zombie9"] = {xpMin = 15, xpMax = 50},
}

function GM:OnNPCKilled( npc, attacker, inflictor )
    if not ZOMBIE_KILL_REWARDS_BOUNTY[npc:GetClass()] or not ZOMBIE_KILL_REWARDS_XP[npc:GetClass()] then return end

    if not attacker:IsPlayer() then return end

    AddBounty(attacker, math.random(ZOMBIE_KILL_REWARDS_BOUNTY[npc:GetClass()].bMin, ZOMBIE_KILL_REWARDS_BOUNTY[npc:GetClass()].bMax))
    AddXP(attacker, math.random(ZOMBIE_KILL_REWARDS_XP[npc:GetClass()].xpMin, ZOMBIE_KILL_REWARDS_XP[npc:GetClass()].xpMax))
end
