local lastBattery = 0
local lastUsedFlash = 0
local stamina = 0
function DoHudPaint()
    --Health
    ----Border
    surface.SetDrawColor(0, 0, 0)
    surface.DrawRect(125, ScrH() - 150, LocalPlayer():GetMaxHealth() / 0.65, 40)
    
    ----Fill
    surface.SetDrawColor(120, 0, 0)
    surface.DrawRect(125, ScrH() - 150, LocalPlayer():Health() / 0.65, 40)
    
    local hpPercent = LocalPlayer():Health() / LocalPlayer():GetMaxHealth() * 100

    draw.SimpleTextOutlined("Health:", "ZWA_Fonts.HUD", 25, ScrH() - 130, Color(255, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0))
    draw.SimpleTextOutlined(hpPercent .. "%", "ZWA_Fonts.HUD", 130, ScrH() - 130, Color(255, 0, 0, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0))

    --Armor
    surface.SetDrawColor(0, 120, 255)
    surface.DrawRect(110, ScrH() - 100, LocalPlayer():GetNWInt("ZWR_Stat_Armor", 0) / 1.25, 35)

    draw.SimpleTextOutlined("Armor:", "ZWA_Fonts.HUD", 25, ScrH() - 85, Color(0, 175, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0))

    --Flashlight
    if LocalPlayer():FlashlightIsOn() or lastUsedFlash > CurTime()  then
        lastBattery = LocalPlayer():GetNWInt("zwa.pl.flashlight", 0)
        
        if lastBattery < 100 then
            lastUsedFlash = 5 + CurTime()
        end

        draw.SimpleTextOutlined("Battery", "ZWA_Fonts.HUD", ScrW() / 2 - 5, ScrH() - 75, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0))

        surface.SetDrawColor(0, 0, 0)
        surface.DrawRect(ScrW() / 2 - 65, ScrH() - 50, 100 * 2, 35)

        if lastBattery <= 25 then
            surface.SetDrawColor(220, 0, 0)
        else
            surface.SetDrawColor(160, 160, 160)
        end

        surface.DrawRect(ScrW() / 2 - 65, ScrH() - 50, lastBattery * 2, 35)
    end

    stamina = LocalPlayer():GetNWInt("zwa.pl.stamina", 0)
        
    draw.SimpleTextOutlined("Stamina:", "ZWA_Fonts.HUD", 25, ScrH() - 40, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, Color(0, 0, 0))

    surface.SetDrawColor(0, 0, 0)
    surface.DrawRect(135, ScrH() - 55, 100, 35)

    surface.SetDrawColor(200, 200, 200)
    surface.DrawRect(135, ScrH() - 55, stamina, 35)
end

function DisplayMessage(message)
    chat.AddText(unpack(message))
end

function PlaySoundMessage(sndPath)
    surface.PlaySound(sndPath)
end

net.Receive("ZWA_PlayerMessage", function()
    DisplayMessage(net.ReadTable())
end)

net.Receive("ZWA_PlayerMsgSound", function()
    PlaySoundMessage(net.ReadString())
end)

local defaultHUD = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
    ["CHudCrosshair"] = true,
    ["CHudWeaponSelection"] = true
}

--Hide the default HUD from displaying
hook.Add( "HUDShouldDraw", "ZWA_HideDefaultHUD", function( name )
    if ( defaultHUD[ name ] ) then
		return false
	end
end)

hook.Add("HUDPaint", "ZWA_Hudpainting", DoHudPaint)