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

local client_timeCycle = 0

local client_timeTillNight = 300
local client_timeTillDay = 600

local client_isDay = client_isDay or true 
local client_isNight = client_isNight or false

hook.Add( "HUDPaint", "ZWR_HUDPaint", function()
	--Faction
    draw.DrawText("Faction: " .. LocalPlayer():GetNWString("ZWR_Faction", "?"), "ZWR_HUD_Faction", 25, ScrH() - 225, Color(255, 255, 255))


    --Health
    ----Border
    surface.SetDrawColor(0, 0, 0)
    surface.DrawRect(110, ScrH() - 150, LocalPlayer():GetMaxHealth() / 0.65, 35)
    
    ----Fill
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

    --Time
    if LocalPlayer():GetNWBool("ZWR_Time_Enable", false) then
        if not LocalPlayer():GetNWBool("ZWR_Time_IsInvasion") then
            draw.DrawText("Time until Invasion: " .. string.FormattedTime( LocalPlayer():GetNWInt("ZWR_Time") - CurTime(), "%02i:%02i" ), "ZWR_HUD_Faction", ScrW() / 1.25, ScrH() - 50, Color(255, 255, 255))
        elseif LocalPlayer():GetNWBool("ZWR_Time_IsInvasion") then
            draw.DrawText("Invasion Time left: " .. string.FormattedTime( LocalPlayer():GetNWInt("ZWR_Time") - CurTime(), "%02i:%02i" ), "ZWR_HUD_Faction", ScrW() / 1.235, ScrH() - 50, Color(255, 255, 255))
        end
    end
    --Nearby friendly NPCs
    for k, ent in pairs(ents.FindByClass("npc_zwr_*")) do
        local distToNPC = LocalPlayer():GetPos():Distance(ent:GetPos())
        local NPCPos = ent:GetPos()
        NPCPos.z = NPCPos.z + 75
        local ScrPosNPC = NPCPos:ToScreen()
        
        if distToNPC <= 150 then
            draw.SimpleText(ent.PrintName, "ZWR_NPC_Name", ScrPosNPC.x, ScrPosNPC.y, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end)

net.Receive("ZWR_BroadcastSound", function()
    surface.PlaySound(net.ReadString())
end)