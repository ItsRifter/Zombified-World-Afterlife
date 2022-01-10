ZOMBIE_KILL_REWARDS = {
    --Basic zombies
    ["npc_vj_zss_zombie"] = {bMin = 25, bMax = 75},
}

function GM:OnNPCKilled( npc, attacker, inflictor )
    if not ZOMBIE_KILL_REWARDS[npc:GetClass()] or string.find(ZOMBIE_KILL_REWARDS, ent:GetClass()) then return end
    
    if not attacker:IsPlayer() then return end

    AddBounty(attacker, math.random(ZOMBIE_KILL_REWARDS[npc:GetClass()].bMin, ZOMBIE_KILL_REWARDS[npc:GetClass()].bMax))
end
