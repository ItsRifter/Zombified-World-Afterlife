include("shared.lua")

include("client/hudbased/cl_zwa_hud.lua")
include("client/hudbased/cl_zwa_tabmenu.lua")
include("client/hudbased/cl_zwa_weaponwheel.lua")
include("client/panels/cl_themes.lua")
include("client/panels/cl_fonts.lua")
include("client/panels/cl_panels.lua")

include("shared/playerbase/sh_player.lua")


function InitializeClient()
    ZWA_Fonts:CreateFont("HUD", 32)
    ZWA_Fonts:CreateFont("NoIcon")
end

hook.Add("Initialize", "ZWA_Init_Client", InitializeClient)