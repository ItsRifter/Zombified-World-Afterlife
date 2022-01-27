AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Faction "
ENT.ClassName = ""

ENT.BaseHealth = 5000
ENT.TimeUntilUpgrade = 0

--Time to wait until an upgrade is possible, to prevent players maximizing their builds in an instant
--in seconds
ENT.TimeToUpgrade = 600
ENT.Invested = 0
ENT.UpgradeReq = 10000

ENT.Model = "models/props_trainstation/trainstation_ornament001.mdl"
ENT.FactionLeader = nil

ENT.BuildMaxCount = 1
ENT.BaseRingRadius = 250
ENT.CurTier = 0

function ENT:Initialize()
    if CLIENT then return end
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:GetPhysicsObject():EnableMotion(false)
    self:BeginTimer()
end

function ENT:BeginTimer()
    self.TimeUntilUpgrade = self.TimeToUpgrade + CurTime()
end

function ENT:OnUse(activator, caller)
    print("Used")
    -- Player check and if they are on the same faction as the leader
    if activator:IsPlayer() then
        if not activator:GetNWString("ZWR_Faction") == FactionLeader:GetNWString("ZWR_Faction") then return end
    else return end

    net.Start("ZWR_FactionBase_InvestFunds_Server")
        net.WriteInt(self.Invested, 32)
        net.WriteInt(self.UpgradeReq, 32)
    net.Send(activator)
end

function ENT:Upgrade()
    if self.TimeUntilUpgrade > CurTime() then return end

    self.CurTier = self.CurTier + 1
    self.UpgradeReq = math.Round(self.UpgradeReq * 2.5)
end