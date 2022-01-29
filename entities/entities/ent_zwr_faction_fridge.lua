AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Fridge"

ENT.BaseHealth = 2000
ENT.Model = "models/props_c17/FurnitureFridge001a.mdl"
ENT.FactionLeader = nil

function ENT:Initialize()
    if CLIENT then return end
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:GetPhysicsObject():EnableMotion(false)
end