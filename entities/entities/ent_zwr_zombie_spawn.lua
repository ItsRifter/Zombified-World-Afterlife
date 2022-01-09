AddCSLuaFile()

ENT.Base = "base_entity"
ENT.Type = "point"

ENT.LastZombies = {}
ENT.SpawnTime = 0
ENT.TotalZombies = ENT.TotalZombies or 0
ENT.MaxZombies = 8


--Spawns the zombie
function ENT:SpawnZombie()
    
    self.SpawnTime = math.random(8, 25) + CurTime()

    --Instead of using the random zombie npc (since it doesn't work well)
    --just use the hardcoded method of getting a random model zombie
    local zombClass = "npc_vj_zss_zombie" .. math.random(1, 9)

    local zombie = ents.Create(zombClass)
    zombie:SetPos(self:GetPos())
    zombie:Spawn()

    --Because of VJ, set the zombies sight and turning speed
    zombie.SightAngle = 180
    zombie.SightDistance = 3500
    zombie.TurningSpeed = 45
    zombie.StartHealth = math.random(50, 100)

    timer.Create("ZWR_ZombieSpawn_" .. zombie:EntIndex(), 0.1, 1, function()
        table.insert(self.LastZombies, zombie)
        self.TotalZombies = self.TotalZombies + 1
    end)
end

function ENT:Think()
    
    if CLIENT then return end

    --If its day, stop here
    if isDayTime then
        return
    end
    
    --If we exceed the total zombies this can spawn, stop here
    if self.TotalZombies >= self.MaxZombies then return end

    for i, z in ipairs(self.LastZombies) do
        if not z:IsValid() or z:Health() <= 0 then
            table.remove(self.LastZombies, i)
            self.TotalZombies = self.TotalZombies - 1
        end
    end

    --If the zombie is too close to spawn, stop here,
    for _, v in pairs(ents.FindInSphere(self:GetPos(), 25)) do
        if v:IsNPC() then
            return
        end
    end
    
    --After the last randomized spawn time is passed and is night time
    --spawn a zombie
    if self.SpawnTime < CurTime() and server_isNightTime then
        self:SpawnZombie()
    end
end
