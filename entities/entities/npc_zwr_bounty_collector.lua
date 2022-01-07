AddCSLuaFile()

ENT.Base = "base_entity"
ENT.Type = "ai"
ENT.Model = "models/player/odessa.mdl"
ENT.PrintName = "Bobby Jr (Bounty Collector)"

local lastUse = 0

function ENT:Initialize()
    self:SetModel(self.Model)
    
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

    if activator:IsPlayer() then
        if activator.curBounty > 0 then
            AddCash(activator, activator.curBounty)
            activator:ChatPrint("Heres " .. activator.curBounty .. " in cash")
            activator.curBounty = 0
        else
            activator:ChatPrint("You don't have any bounty, get to killing")
        end
    end
end

function ENT:OnTakeDamage( dmgInfo )
    return false
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

