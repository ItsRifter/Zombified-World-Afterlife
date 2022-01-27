AddCSLuaFile()

SWEP.Author         = "Rifter"
SWEP.Base           = "weapon_base"
SWEP.PrintName      = "Faction Deconstructer"
SWEP.Instructions   = "Mouse 1: Destroy the desired building"

SWEP.ViewModel      = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel     = "models/weapons/w_crowbar.mdl"

SWEP.Weight         = 0
SWEP.Slot           = 4

SWEP.DrawAmmo       = false 
SWEP.DrawCrosshair  = true

SWEP.SetHoldType    = "melee"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = -1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = -1

SWEP.DestroyRange = 150
SWEP.Delay = 2
SWEP.NextDeconstruct = 0

function SWEP:Deploy()
    return true
end

function SWEP:PrimaryAttack()
    if self.NextDeconstruct > CurTime() then return end

    local tr = util.TraceLine({
        start = self.Owner:EyePos(),
        endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * self.DestroyRange,
        filter = self.Owner
    } )
    
    if tr.Hit and tr.Entity.FactionLeader == self.Owner then
        for i, b in pairs(self.Owner.Buildings) do
            if b == tr.Entity:GetClass() then
                table.remove(self.Owner.Buildings, i)
            end
        end
        tr.Entity:Remove()
    end

    self.NextDeconstruct = self.Delay + CurTime()
end

function SWEP:SecondaryAttack()
    return false
end

function SWEP:Holster()
    return true
end