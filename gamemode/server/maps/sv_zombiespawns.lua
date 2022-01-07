ZOMBIE_SPAWN_MAPS = {
    ["rp_lr_refuge_v1"] = {
        [1] = Vector(31, -5063, 486),
        [2] = Vector(33, -4202, 486),
    },

    ["gm_aftermath_day_v1_0"] = {
        [1] = Vector( 336, 534, 80 ),
        [2] = Vector(1358, 515, 96),
        [3] = Vector(764, -275, 83),
        [4] = Vector(1370, -1092, 72),
        [5] = Vector(3147, -190, 80),
        [6] = Vector(2122, 892, 80),
        [7] = Vector(1985, -152, 64),
        [8] = Vector(2737, 1390, 112),
        [9] = Vector(370, 2184, 102),
        [10] = Vector(2479, 2357, 71),
        [11] = Vector(1510, 2691, 73),
    },
}

function SetUpZombieSpawns()
    if not ZOMBIE_SPAWN_MAPS[game.GetMap()] then print("UNSUPPORTED MAP FOR ZW:R") return end

    for i = 1, #ZOMBIE_SPAWN_MAPS[game.GetMap()] do
        local spawnpoint = ents.Create("ent_zwr_zombie_spawn")
        spawnpoint:SetPos(ZOMBIE_SPAWN_MAPS[game.GetMap()][i])
        spawnpoint:Spawn()
    end
end

function GM:PostCleanupMap()
    SetUpZombieSpawns()
end

function GM:InitPostEntity()
    SetUpZombieSpawns()
end

