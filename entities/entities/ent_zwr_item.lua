AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Item: "
ENT.ClassName = ""

function ENT:Initialize()
    if CLIENT then return end
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Use(activator, caller)
    if activator:IsPlayer() and not InventoryHasItem(activator, self.ClassName) then
        InventoryGiveItem(activator, self.ClassName)
        self:Remove()
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end
