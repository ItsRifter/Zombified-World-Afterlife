local defaultHUD = {
	["CHudHealth"] = true,
	["CHudBattery"] = true
}

--Hide the default HUD from displaying
hook.Add( "HUDShouldDraw", "ZWR_HideDefaultHUD", function( name )
	if ( defaultHUD[ name ] ) then
		return false
	end
end)

hook.Add( "HUDPaint", "ZWR_HUDPaint", function()
	--Faction
    draw.DrawText("Faction: " .. LocalPlayer():GetNWString("ZWR_Stat_Faction", "Loner"), "ZWR_HUD_Faction", 25, ScrH() - 225, Color(255, 255, 255))

    --Health
    surface.SetDrawColor(120, 0, 0)
    surface.DrawRect(110, ScrH() - 150, LocalPlayer():Health() * 1.15, 35)
    
    draw.DrawText("Health", "ZWR_HUD_Health", 25, ScrH() - 150, Color(255, 0, 0, 255))
    
    --Armor
    surface.SetDrawColor(0, 120, 255)
    surface.DrawRect(110, ScrH() - 100, LocalPlayer():GetNWInt("ZWR_Stat_Armor", 0) / 1.25, 35)

    draw.DrawText("Armor", "ZWR_HUD_Health", 25, ScrH() - 100, Color(0, 175, 255))

    --Stamina
    surface.SetDrawColor(160, 160, 160)
    surface.DrawRect(110, ScrH() - 50, LocalPlayer():GetNWInt("ZWR_Stat_Stamina", 0) / 1.5, 35)

    draw.DrawText("Stamina", "ZWR_HUD_Stamina", 25, ScrH() - 50, Color(255, 255, 255))
end)