AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Item: "
ENT.ClassName = ""

ENT.BaseHealth = 5000
ENT.TimeUntilUpgrade = 0
ENT.Invested = 0
ENT.UpgradeReq = 10000

ENT.Model = "models/props_trainstation/trainstation_ornament001.mdl"

ENT.BuildMaxCount = 1

function ENT:Initialize()
    if CLIENT then return end
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
end


