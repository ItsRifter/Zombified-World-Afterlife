function CreateFaction(name, inviteOnly)
    print(name)
    print(inviteOnly)
end

net.Receive("ZWR_Faction_Create", function(len, ply)
    if not ply then return end

    local factionName = net.ReadString()
    local isInviteOnly = net.ReadBool()
    CreateFaction(factionName, isInviteOnly)
end)