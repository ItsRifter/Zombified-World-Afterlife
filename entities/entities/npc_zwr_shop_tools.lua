AddCSLuaFile()

ENT.Base = "base_entity"
ENT.Type = "ai"
ENT.Model = "models/player/odessa.mdl"

ENT.PotentialNames = {
    [1] = "Richard",
    [2] = "Adam",
    [3] = "Bill"
}

local lastUse = 0

function ENT:Initialize()
    self:SetModel(self.Model)
    self.PrintName = self.PotentialNames[math.random(1, #self.PotentialNames)] .. " (Tools Dealer)"
    
    if SERVER then
        self:SetActivity(ACT_IDLE)
        self:SetHullType(HULL_HUMAN)
        self:SetHullSizeNormal()
        self:SetNPCState(NPC_STATE_IDLE)
        self:SetSolid(SOLID_BBOX)
        self:DropToFloor()
    end
end

function ENT:Use(activator, caller)
    if lastUse > CurTime() then return end

    lastUse = 1 + CurTime()

    net.Start("ZWR_OpenShop")
    net.WriteString("tool")
    net.Send(activator)
end

function ENT:OnTakeDamage( dmgInfo )
    return false
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

