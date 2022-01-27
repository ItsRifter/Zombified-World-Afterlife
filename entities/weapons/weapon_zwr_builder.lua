AddCSLuaFile()

if SERVER then
    util.AddNetworkString("ZWR_Builder_Update")
end

SWEP.Author         = "Rifter"
SWEP.Base           = "weapon_base"
SWEP.PrintName      = "Faction Construction Builder"
SWEP.Instructions   = "Mouse 1: Build the desired construction\nMouse 2: Select construction"

SWEP.ViewModel      = "models/weapons/c_slam.mdl"
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
SWEP.NextOpenMenu = 0

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

    --Checks suitability of the desired spot
    --basically checks if on the floor and not on a slope/wall
    local cosine = tr.HitNormal:Dot(Vector(0, 0, 1))
    
    if cosine < 0.2588190451 then
        return
    elseif cosine < 0.7071067812 then
        return
    elseif self:InWallOrNearProp() then 
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

local curFrame = nil

function SWEP:SecondaryAttack()
    if SERVER then return end
    if self.NextOpenMenu > CurTime() then return end
    if curFrame and curFrame:IsValid() then return end 

    self.NextOpenMenu = self.Delay + CurTime()

    local buildingsFrame = vgui.Create("DFrame")
    buildingsFrame:SetTitle("")
    buildingsFrame:SetSize(ScrW() / 1.5, ScrH() / 1.25)
    buildingsFrame:SetDraggable(false)
    buildingsFrame:Center()
    buildingsFrame:MakePopup()

    local buildScroll = vgui.Create( "DScrollPanel", buildingsFrame )
    buildScroll:Dock( FILL )

    local buildList = vgui.Create("DIconLayout", buildScroll)
    buildList:Dock( FILL )
    buildList:SetSpaceY( 5 )
    buildList:SetSpaceX( 5 )

    for _, building in pairs(GAMEMODE.DB.Buildings) do
        local bPanel = buildList:Add("DPanel")
        bPanel:SetSize(350, 250)
        bPanel.Paint = function(self, w, h)
            surface.SetDrawColor(Color(0, 0, 0, 255))
            surface.DrawRect(0, 0, w, h)
        end

        local bModel = vgui.Create("DModelPanel", bPanel)
        bModel:SetModel(building.Model)
        bModel:SetSize(bPanel:GetWide() / 2, bPanel:GetTall())
        bModel:SetPos(bPanel:GetWide() / 2, bPanel:GetTall() / 12)
        function bModel:LayoutEntity( ent ) return end

        local bDesc = vgui.Create("DLabel", bPanel)
        bDesc:SetText(building.Name .. "\n" .. building.Desc .. "\nCost: " .. building.Cost)
        bDesc:SetFont("ZWR_QMenu_Faction_BuildDesc")
        bDesc:SizeToContents()

        local selectBtn = vgui.Create("DButton", bPanel)
        selectBtn:SetText("Select Building")
        selectBtn:SetSize(128, 32)
        selectBtn:SetPos(0, bPanel:GetTall() - selectBtn:GetTall())
        selectBtn.DoClick = function()
            if curFrame and curFrame:IsValid() then
                curFrame:Remove()
                net.Start("ZWR_Builder_Update")
                    net.WriteString(building.Class)
                net.SendToServer()
            end
        end
    end

    curFrame = buildingsFrame
end

function SWEP:Think()
    net.Receive("ZWR_Builder_Update", function()
        local holoClass = net.ReadString()
        self.Owner.HoloBuild = ents.Create(holoClass)
        self:DrawPreviewModel()
        print("Works")
    end)

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
                return false 
            end

            if ent == self.Owner then
                return false 
            end
        end
    } )

    local cosine = tr.HitNormal:Dot(Vector(0, 0, 1))
    
    if tr.Hit and tr.HitWorld and tr.HitNormal.z ~= 1 then
        tr.HitPos = tr.HitPos + tr.HitNormal * self.Owner.HoloBuild:BoundingRadius() / 2
    end
    
    if self.Owner.HoloBuild and self.Owner.HoloBuild:IsValid() then
        if not tr.Hit then
            self.Owner.HoloBuild:SetColor(Color(255, 0, 0))
        elseif cosine < 0.2588190451 then
            self.Owner.HoloBuild:SetColor(Color(255, 0, 0))
        elseif cosine < 0.7071067812 then
            self.Owner.HoloBuild:SetColor(Color(255, 0, 0))
        elseif self:InWallOrNearProp() then
            self.Owner.HoloBuild:SetColor(Color(255, 0, 0))
        else
            self.Owner.HoloBuild:SetColor(Color(0, 255, 0))
        end
    end

    self.Owner.HoloBuild:SetPos(tr.HitPos)
end

--Checks if the desired building is in a wall or near a prop
function SWEP:InWallOrNearProp()
   
    local buildCenter = self.Owner.HoloBuild:WorldSpaceCenter()

    for _, ent in pairs(ents.FindInSphere(buildCenter, self.Owner.HoloBuild:BoundingRadius())) do
        if ent and ent ~= self.Owner.HoloBuild and ent:IsValid() then
			local nearest = ent:NearestPoint(buildCenter)
			if self.Owner.HoloBuild:NearestPoint(nearest):DistToSqr(nearest) <= 144 then
				return true
			end
		end
	end

    return false
end

