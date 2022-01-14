AddCSLuaFile()

SWEP.Author         = "Rifter"
SWEP.Base           = "weapon_base"
SWEP.PrintName      = "Faction Construction Builder"
SWEP.Instructions   = "Mouse 1: Build the desired construction\nMouse 2: Select construction"

SWEP.ViewModel      = ""
SWEP.WorldModel     = "models/weapons/w_slam.mdl"

SWEP.Weight         = 0
SWEP.Slot           = 4

SWEP.DrawAmmo       = false 
SWEP.DrawCrosshair  = true

SWEP.SetHoldType    = "slam"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = -1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = -1

SWEP.BuildRange = 150
SWEP.Delay = 2
SWEP.NextBuild = 0

function SWEP:Deploy()
    self.Owner.Buildings = self.Owner.Buildings or {}
end


function SWEP:PrimaryAttack()
    if self.NextBuild > CurTime() then return end
    if self.Owner.HoloBuild == nil or not self.Owner.HoloBuild:IsValid() then return end
    
    for i, b in pairs(self.Owner.Buildings) do
        if not self.Owner.Buildings[i] then continue end
        if self.Owner.Buildings[i] == self.Owner.HoloBuild:GetClass() then
            if not self.Owner.TotalBuilding then
                self.Owner.TotalBuilding = 1
            end

            self.Owner.TotalBuilding = self.Owner.TotalBuilding + 1

            if self.Owner.TotalBuilding >= self.Owner.HoloBuild.BuildMaxCount then 
                self.Owner:ChatPrint("You have exceeded the max limit for this building")
                self.Owner.TotalBuilding = nil
                self.NextBuild = self.Delay + CurTime()
                return 
            end
        end
        
    end

    local tr = util.TraceLine({
        start = self.Owner:EyePos(),
        endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * self.BuildRange,
        filter = function( ent ) 
            if ent:GetClass() == self.Owner.HoloBuild then 
                return true 
            end
        end
    } )

    local cosine = tr.HitNormal:Dot(Vector(0, 0, 1))
    
    if cosine < 0.2588190451 then
        return
    elseif cosine < 0.7071067812 then
        return
    end
    
    local building = ents.Create(self.Owner.HoloBuild:GetClass())
    building:SetPos(tr.HitPos) 
    building:Spawn()

    building.FactionLeader = self.Owner

    table.insert(self.Owner.Buildings, self.Owner.HoloBuild:GetClass())

    self.Owner.HoloBuild:Remove()
    self.Owner:EmitSound("buttons/lever" .. math.random(3, 6) .. ".wav")

    self.NextBuild = self.Delay + CurTime()
end

function SWEP:SecondaryAttack()
    if CLIENT then return end

    if not self.Owner.HoloBuild or not self.Owner.HoloBuild:IsValid() then 
        self.Owner.HoloBuild = ents.Create("ent_zwr_faction_base")
        self.Owner.HoloBuild:Spawn()
    end
end

function SWEP:Think()
    if self.Owner.HoloBuild == nil or not self.Owner.HoloBuild:IsValid() then return end
    self:DrawPreviewModel()
end

function SWEP:Holster()
    if CLIENT then return end

    if self.Owner.HoloBuild and self.Owner.HoloBuild:IsValid() then
        self.Owner.HoloBuild:Remove()
    end

    return true
end

function SWEP:DrawPreviewModel()
    local tr = util.TraceLine({
        start = self.Owner:EyePos(),
        endpos = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * self.BuildRange,
        filter = function( ent ) 
            if ent:GetClass() == self.Owner.HoloBuild then 
                return true 
            end

            if ent == self.Owner then
                return false 
            end
        end
    } )

    local cosine = tr.HitNormal:Dot(Vector(0, 0, 1))
    
    if not tr.Hit then
        self.Owner.HoloBuild:SetColor(Color(255, 0, 0))
    end

    if self.Owner.HoloBuild and self.Owner.HoloBuild:IsValid() then
        if cosine < 0.2588190451 then
            self.Owner.HoloBuild:SetColor(Color(255, 0, 0))
        elseif cosine < 0.7071067812 then
            self.Owner.HoloBuild:SetColor(Color(255, 0, 0))
        else
            self.Owner.HoloBuild:SetColor(Color(0, 255, 0))
        end
    end

    self.Owner.HoloBuild:SetPos(tr.HitPos)

end
