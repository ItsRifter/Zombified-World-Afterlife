ENT.Base = "base_brush"
ENT.Type = "brush"

ENT.NextSpawn = -1
ENT.SpawnCap = 7
ENT.Zombs = {}

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetCollisionBoundsWS(self.Min, self.Max)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetMoveType(0)
end

function ENT:Think()
    if GetGlobalBool("zwa_cycle_isnight") == false then return end

    for i, z in ipairs(self.Zombs) do
        if !z:IsValid() then
            table.remove(self.Zombs, i)
        end
    end

    if #self.Zombs >= self.SpawnCap then return end
    
    if self.NextSpawn > CurTime() then return end

    if self.NextSpawn < CurTime() then
        self:SpawnNPC()
        self.NextSpawn = math.random(10, 25) + CurTime()
    end
end

function ENT:SpawnNPC()
    local zomb = nil
    local randGender = math.random(1, 2)
    if randGender == 1 then
        zomb = ents.Create("npc_vj_con_zmale")
    elseif randGender == 2 then
        zomb = ents.Create("npc_vj_con_zfemale")
    end
   
    zomb:SetPos(VectorRand(self.Min, self.Max))
    //zomb:SetPos(Vector( 3915, 2333, 279))
    zomb:Spawn()
    zomb:SetPos(zomb:GetPos() + Vector(0, 0, 100))
    table.insert(self.Zombs, zomb)
end