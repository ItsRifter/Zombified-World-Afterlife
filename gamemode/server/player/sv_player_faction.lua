CURRENT_FACTIONS = CURRENT_FACTIONS or {}
function CreateFaction(ply, name, inviteOnly, colour)

    local newFaction = {
        ["name"] = name,
        ["owner"] = ply,
        ["inviteOnly"] = inviteOnly,
        ["colour"] = colour,
        ["curPlayers"] = {
            [1] = ply
        }
    }

    ply.faction = newFaction

    table.insert(CURRENT_FACTIONS, ply.faction)

    ply:SetNWString("ZWR_Faction", ply.faction.name)
    
    net.Start("ZWR_Faction_Create_Server")
        net.WriteString(ply.faction.name)
        net.WriteEntity(ply.faction.owner)
        net.WriteBool(ply.faction.inviteOnly)
        //net.WriteTable(ply.faction.colour)
        net.WriteTable(ply.faction.curPlayers)
    net.Broadcast()

    ply:Give("weapon_zwr_builder")
    ply:Give("weapon_zwr_deconstructor")
end

net.Receive("ZWR_Faction_Discard", function(len, ply)
    if not ply then return end

    local factionName = net.ReadString()
    
    for i, f in pairs(CURRENT_FACTIONS) do
        if f.name == factionName then
            table.remove(CURRENT_FACTIONS, i)
        end
    end

    ply:SetNWString("ZWR_Faction", "Loner")

    net.Start("ZWR_Faction_Discard_Server")
        net.WriteString(ply.faction.name)
    net.Broadcast()

    ply:StripWeapon("weapon_zwr_builder")
    ply:StripWeapon("weapon_zwr_deconstructor")
end)

net.Receive("ZWR_Faction_Create", function(len, ply)
    if not ply then return end

    local factionName = net.ReadString()
    local isInviteOnly = net.ReadBool()
    local colourR = net.ReadInt(32)
    local colourG = net.ReadInt(32)
    local colourB = net.ReadInt(32)

    local factionColour = {
        ["r"] = colourR,
        ["g"] = colourG,
        ["b"] = colourB,
    }

    CreateFaction(ply, factionName, isInviteOnly, factionColour)
end)

net.Receive("ZWR_Faction_Leave", function(len, ply)
    if not ply then return end

    for _, f in pairs(CURRENT_FACTIONS) do
        for i, p in pairs(f.curPlayers) do
            if ply == p then
                net.Start("ZWR_Faction_Leave_Server")
                    net.WriteString(f.name)
                    net.WriteEntity(p)
                net.Broadcast()
                
                table.remove(f.curPlayers, i)
                ply:SetNWString("ZWR_Faction", "Loner")
            end
        end
    end
end)

net.Receive("ZWR_Faction_Join", function(len, ply)
    if not ply then return end

    local factionName = net.ReadString()
    
    for i, f in pairs(CURRENT_FACTIONS) do
        if f.name == factionName then
            table.insert(f.curPlayers, ply) 
            
            net.Start("ZWR_Faction_Join_Server")
                net.WriteString(f.name)
                net.WriteEntity(ply)
            net.Broadcast()

            ply:SetNWString("ZWR_Faction", f.name)
        end
    end
end)