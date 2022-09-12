
function IsMapSupported(map)
    return ZWA_Maps[map] ~= nil
end

function SetUpNPCSpawns()
    if !IsMapSupported(game.GetMap()) then 
        MsgC(Color(255, 0, 0), "This map does not support ZW:A\n")
        return
    end

    for _, s in ipairs(ZWA_Maps[game.GetMap()]) do
        local zSpawnBox = ents.Create("ent_zombie_spawnbox")
        zSpawnBox.Min = Vector(s[1])
        zSpawnBox.Max = Vector(s[2])
        zSpawnBox:Spawn()
    end
end