ZOMBIE_SPAWN_MAPS = {
    ["rp_lr_refuge_v1"] = {
        [1] = Vector(31, -5063, 486),
        [2] = Vector(33, -4202, 486),
    },

    ["gm_aftermath_thelast"] = {
        --City
        [1] = Vector(6648, 10755, 130),
        [2] = Vector(6656, 8639, 105),
        [3] = Vector(6691, 12801, 101),
        [4] = Vector(4921, 12799, 117),
        [5] = Vector(3606, 12802, 119),
        [6] = Vector(2935, 9729, 123),

        --City: Hospital
        [7] = Vector(2720, 10365, 117),
        [8] = Vector(3585, 10762, 112),

        --Rural
        [9] = Vector(751, 508, 28),
        [10] = Vector(3035, 1295, 64),
        [11] = Vector(185, 2631, 49),

        --Tunnels
        [12] = Vector(4983, 1778, 53),
        [13] = Vector(5333, 1295, 59),

        --Missile Base
        [14] = Vector(-9571, 3692, 148),
        [15] = Vector(-10210, 1992, 136),
        [16] = Vector(-10498, 1226, 140),

        --Swamp
        [17] = Vector(-8731, 12052, 91),
        [18] = Vector(-4936, 10420, 67),    
        [19] = Vector(-10493, 10905, 84),
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

    ["gm_aftermath_thelast"] = { 
        ["weapons"] = {
            [1] = {
                ["pos"] = Vector(6611, -419, 57),
                ["angle"] = Angle(0, 90, 0)
            },

            [2] = {
                ["pos"] = Vector(4229, 11552, 131),
                ["angle"] = Angle(0, 180, 0),
            },

            [3] = {
                ["pos"] = Vector(-11133, 3614, -12),
                ["angle"] =  Angle(0, 90, 0)
            },

        },

        ["bountyCollection"] = {
            [1] = {
                ["pos"] = Vector(6491, -433, 181),
                ["angle"] = Angle(0, 90, 0)
            },

            [2] = {
                ["pos"] = Vector(4255, 9099, 140),
                ["angle"] = Angle(0, 0, 0)
            },

            [3] = {
                ["pos"] = Vector(-10301, 3361, -27),
                ["angle"] = Angle(0, -90, 0)
            }
        },

        ["tools"] = {
            [1] = {
                ["pos"] = Vector(6958, -266, 46),
                ["angle"] = Angle(0, 180, 0)
            },

            [2] = {
                ["pos"] = Vector(2604, 11360, 244),
                ["angle"] = Angle(0, 180, 0)
            },

            [3] = {
                ["pos"] = Vector(-10249, 2834, -24),
                ["angle"] = Angle(0, 90, 0)
            }
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

