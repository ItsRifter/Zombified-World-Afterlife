local defaultHUD = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
    ["CHudCrosshair"] = true
}

--Hide the default HUD from displaying
hook.Add( "HUDShouldDraw", "ZWR_HideDefaultHUD", function( name )
    if ( defaultHUD[ name ] ) then
		return false
	end
end)

local lastBattery = 0
local lastUsedFlash = 0

hook.Add( "HUDPaint", "ZWR_HUDPaint", function()
	--Faction
    draw.DrawText("Faction: " .. LocalPlayer():GetNWString("ZWR_Faction", "Loner"), "ZWR_HUD_Faction", 25, ScrH() - 225, Color(255, 255, 255))

    --Health
    surface.SetDrawColor(120, 0, 0)
    surface.DrawRect(110, ScrH() - 150, LocalPlayer():Health() / 0.65, 35)
    
    draw.DrawText("Health", "ZWR_HUD_Health", 25, ScrH() - 150, Color(255, 0, 0, 255))
    
    --Armor
    surface.SetDrawColor(0, 120, 255)
    surface.DrawRect(110, ScrH() - 100, LocalPlayer():GetNWInt("ZWR_Stat_Armor", 0) / 1.25, 35)

    draw.DrawText("Armor", "ZWR_HUD_Health", 25, ScrH() - 100, Color(0, 175, 255))

    --Stamina
    surface.SetDrawColor(160, 160, 160)
    surface.DrawRect(110, ScrH() - 50, LocalPlayer():GetNWInt("ZWR_Stat_Stamina", 0) / 1.5, 35)

    draw.DrawText("Stamina", "ZWR_HUD_Stamina", 25, ScrH() - 50, Color(255, 255, 255))

    --Flashlight
   
    if LocalPlayer():FlashlightIsOn() or lastUsedFlash > CurTime()  then
        lastBattery = LocalPlayer():GetNWInt("ZWR_Stat_FlashlightBattery")
        
        if lastBattery < 100 then
            lastUsedFlash = 5 + CurTime()
        end

        draw.DrawText("Battery", "ZWR_HUD_Stamina", ScrW() / 2.09, ScrH() - 75, Color(255, 255, 255))

        if lastBattery <= 25 then
            surface.SetDrawColor(220, 0, 0)
        else
            surface.SetDrawColor(160, 160, 160)
        end

        surface.DrawRect(ScrW() / 2.25, ScrH() - 50, LocalPlayer():GetNWInt("ZWR_Stat_FlashlightBattery", 0) * 2, 35)
    end
end)

net.Receive("ZWR_BroadcastSound", function()
    surface.PlaySound(net.ReadString())
end)