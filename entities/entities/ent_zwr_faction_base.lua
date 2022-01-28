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

ENT.Delay = 1
ENT.NextOpenMenu = 0

function ENT:Initialize()
    if CLIENT then return end
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:GetPhysicsObject():EnableMotion(false)
end

function ENT:AssignLeader(ply)
    self.FactionLeader = ply
    self:SetNWString("ZWR_Base_LeaderName", self.FactionLeader:Nick())
end

function ENT:BeginTimer()
    self.TimeUntilUpgrade = self.TimeToUpgrade + CurTime()
end

function ENT:Upgrade()
    self.CurTier = self.CurTier + 1
    self.Invested = 0
    self.UpgradeReq = math.Round(self.UpgradeReq * 2.5)
end

function ENT:Think()
    if self.TimeUntilUpgrade < CurTime() and self.Invested >= self.UpgradeReq then
        self:Upgrade()
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()

        cam.Start3D2D(self:GetPos() - Vector(-38, -21, -30), Angle(0, 180, 90), 0.5)
        
            surface.SetDrawColor(Color(100, 100, 100))
            surface.DrawRect(25, -50, 100, 50)
            
            surface.SetFont( "ZWR_QMenu_Faction_BuildOwner" )
            surface.SetTextColor( 255, 255, 255 )
            surface.SetTextPos( 25, -50 ) 
            surface.DrawText(self:GetNWString("ZWR_Base_LeaderName") .. "'s Base")
            
            surface.SetTextColor( 190, 0, 0)
            surface.SetTextPos( 25, -35 ) 
            surface.DrawText("Health: " .. self.BaseHealth)
            
            surface.SetTextColor( 255, 255, 255)
            surface.SetTextPos( 25, -15 ) 
            surface.DrawText("Tier: " .. self.CurTier)
            
        cam.End3D2D()

    end
end