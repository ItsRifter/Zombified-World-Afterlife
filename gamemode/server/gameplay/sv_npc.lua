ZOMBIE_KILL_REWARDS = {
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

function GM:OnNPCKilled( npc, attacker, inflictor )
    if not ZOMBIE_KILL_REWARDS[npc:GetClass()] then return end
    
    if not attacker:IsPlayer() then return end

    AddBounty(attacker, math.random(ZOMBIE_KILL_REWARDS[npc:GetClass()].bMin, ZOMBIE_KILL_REWARDS[npc:GetClass()].bMax))
end
