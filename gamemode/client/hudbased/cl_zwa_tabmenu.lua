local tabFrame = nil 
local lastActive = 1

function TabInvMenu(showMenu)
    
    if showMenu then
        tabFrame = vgui.Create("ZWA_Frame_Navbar")
        tabFrame:SetSize(ScrW() / 1.25, ScrH() / 1.5)
        tabFrame:Center()
        tabFrame:SetTitle(GetHostName())
        tabFrame:MakePopup()
        
        local inventory = vgui.Create("ZWA_Panel_Inventory")
        
        local slotLayout = vgui.Create("DIconLayout", inventory)
        slotLayout:SetWide(ZWA_UISizes.invPanel.width * 2)
        slotLayout:SetSize(slotLayout:GetWide(), inventory:GetTall())
        slotLayout:SetPos(0, ZWA_UISizes.invPanel.height - 128)
        
        for i = 1, 24 do
            slotLayout:Add(inventory:AddSlot(i))
        end

        tabFrame.navbar:AddTab("Inventory", inventory)
        tabFrame.navbar:AddTab("Factions")

        tabFrame.navbar:SetActive(lastActive)

    elseif not showMenu and IsValid(tabFrame) then
        lastActive = tabFrame.navbar:GetActive()
        tabFrame:Remove()
        tabFrame = nil
    end
end

hook.Add( "ScoreboardShow", "ZWA_TabMenu_Open", function()
    TabInvMenu(true)
    return true
end)

hook.Add( "ScoreboardHide", "ZWA_TabMenu_Close", function()
    TabInvMenu(false)
end)