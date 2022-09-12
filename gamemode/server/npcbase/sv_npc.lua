local ZWA_NPC = FindMetaTable("NPC")

ZWA_Reward_Tbl = {
    ["npc_vj_con_zfemale"] = {
        Bounty = {Min = 1, Max = 50}
    },

    ["npc_vj_con_zmale"] = {
        Bounty = {Min = 1, Max = 50}
    }
}

function ZWA_NPC:OnKilledByPlayer(pl)
    local amtLimit = ZWA_Reward_Tbl[self:GetClass()].Bounty
    local reward = math.random(amtLimit.Min, amtLimit.Max)

    pl.bounty = pl.bounty + reward
end

hook.Add("OnNPCKilled", "ZWA_NPC_Killed", function(npc, attacker, inflictor)
    if attacker:IsPlayer() then
        npc:OnKilledByPlayer(attacker)
    end
end)