AddCSLuaFile()

ENT.Base = "base_entity"
ENT.Type = "point"

ENT.LastZombies = {}
ENT.SpawnTime = 0
ENT.TotalZombies = 0
ENT.MaxZombies = 3
--sent_vj_zss_zombierand

--Spawns the zombie
function ENT:SpawnZombie()
    
    self.SpawnTime = math.random(6, 15) + CurTime()

    local zombie = ents.Create("sent_vj_zss_zombierand")
    zombie:SetPos(self:GetPos())
    zombie:Spawn()

    --Because of VJ, set the zombies sight and turning speed
    zombie.SightAngle = 180
    zombie.SightDistance = 3500
    zombie.TurningSpeed = 45
    zombie.StartHealth = math.random(50, 100)

    table.insert(self.LastZombies, zombie:EntIndex())

    self.TotalZombies = self.TotalZombies + 1
end

function ENT:Think()
    
    if CLIENT then return end

    --If its day, stop here
    if isDayTime then
        return
    end
    
    for i, z in ipairs(self.LastZombies) do
        if not z:IsValid() then
            table.remove(self.LastZombies, i)
        end
    end

    for _, v in pairs(ents.FindInSphere(self:GetPos(), 25)) do
        if v:IsNPC() then
            return 
        end
    end
    
    --After the last randomized spawn time is passed, is night time
    --spawn a zombie
    if self.SpawnTime < CurTime() and isNightTime then
        self:SpawnZombie()
    end
end
