ZOMBIE_SPAWN_MAPS = {
    ["rp_lr_refuge_v1"] = {
        [1] = Vector(31, -5063, 486),
        [2] = Vector(33, -4202, 486),
    },

    ["gm_aftermath_day_v1_0"] = {
        [1] = Vector(764, 1760, 70),
        [2] = Vector(-363, 3471, 46),
        [3] = Vector(4997, 11409, 129),
        [4] = Vector(5649, 11839, 115),
        [5] = Vector(2068, 9338, 127),
        [6] = Vector(-6399, 4578, 61),
        [7] = Vector(-10296, 2301, 143),
        [8] = Vector(-6845, 13071, 116),
        [9] = Vector(-8835, 8782, 35),
        [10] = Vector(6602, 6158, 29),
        [11] = Vector(7355, 2984, 34),
    },
}

FRIENDLY_SPAWN_MAPS = {
    ["rp_lr_refuge_v1"] = {
        --TODO: Add weapon + bounty pos and angles
    },

    ["zw_coast_v3"] = {
        ["weapons"] = {
            [1] = {
                ["pos"] = Vector(4952, 3964, 393),
                ["angle"] = Angle(0, 90, 0)
            }
        },

        ["bountyCollection"] = {
            [1] = {
                ["pos"] = Vector(4341, 4371, 392),
                ["angle"] = Angle(0, 0, 0)
            }
        },

        ["tools"] = {
            [1] = {
                ["pos"] = Vector(4651, 4306, 520),
                ["angle"] = Angle(0, 0, 0)
            },
        },
    },

    ["gm_aftermath_day_v1_0"] = { 
        ["weapons"] = {
            [1] = {
                ["pos"] = Vector(-4510, 10398, 63),
                ["angle"] = Angle(0, 0, 0)
            },

            [2] = {
                ["pos"] = Vector(-8454, 11698, 56),
                ["angle"] = Angle(0, 180, 0)
            },
        },

        ["bountyCollection"] = {
            [1] = {
                ["pos"] = Vector(-4198, 10283, 57),
                ["angle"] = Angle(0, 180, 0)
            },
        },
    },
}

function SetUpZombieSpawns()
    if not ZOMBIE_SPAWN_MAPS[game.GetMap()] then print("THIS MAP DOESN'T HAVE ZW:R ZOMBIE SPAWNS") return end

    for i = 1, #ZOMBIE_SPAWN_MAPS[game.GetMap()] do
        local spawnpoint = ents.Create("ent_zwr_zombie_spawn")
        spawnpoint:SetPos(ZOMBIE_SPAWN_MAPS[game.GetMap()][i])
        spawnpoint:Spawn()
    end
end

function SetUpFriendlySpawns()
    if not FRIENDLY_SPAWN_MAPS[game.GetMap()] then print("THIS MAP DOESN'T HAVE ZW:R FRIENDLY SPAWNS") return end
   
    for i = 1, #FRIENDLY_SPAWN_MAPS[game.GetMap()]["weapons"] do
        local shops = ents.Create("npc_zwr_shop_weapons")
        shops:SetPos(FRIENDLY_SPAWN_MAPS[game.GetMap()]["weapons"][i]["pos"])
        shops:SetAngles(FRIENDLY_SPAWN_MAPS[game.GetMap()]["weapons"][i]["angle"])
        shops:Spawn()
    end

    for i = 1, #FRIENDLY_SPAWN_MAPS[game.GetMap()]["bountyCollection"] do
        local bountyPoint = ents.Create("npc_zwr_bounty_collector")
        bountyPoint:SetPos(FRIENDLY_SPAWN_MAPS[game.GetMap()]["bountyCollection"][i]["pos"])
        bountyPoint:SetAngles(FRIENDLY_SPAWN_MAPS[game.GetMap()]["bountyCollection"][i]["angle"])
        bountyPoint:Spawn()
    end

    for i = 1, #FRIENDLY_SPAWN_MAPS[game.GetMap()]["tools"] do
        local bountyPoint = ents.Create("npc_zwr_shop_tools")
        bountyPoint:SetPos(FRIENDLY_SPAWN_MAPS[game.GetMap()]["tools"][i]["pos"])
        bountyPoint:SetAngles(FRIENDLY_SPAWN_MAPS[game.GetMap()]["tools"][i]["angle"])
        bountyPoint:Spawn()
    end
end

function GM:PostCleanupMap()
    SetUpZombieSpawns()
    SetUpFriendlySpawns()
end

function GM:InitPostEntity()
    SetUpZombieSpawns()
    SetUpFriendlySpawns()
end

