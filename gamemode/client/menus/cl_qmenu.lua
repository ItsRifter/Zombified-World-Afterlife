local clientQMenu = nil

function QMenu()
    
    --Base
    local QFrame = vgui.Create("ZWR_Tab")
    QFrame:SetPos(ScrW() / 8, ScrH() / 6)
    QFrame:SetSize(ScrW() / 1.35, ScrH() / 1.45)
    
    --Inventory
    local QInvPnl = vgui.Create("DPanel", QFrame)    
    QInvPnl:SetSize(QFrame:GetWide(), 600)

    local QInvBG = vgui.Create("DPanel", QInvPnl)
    QInvBG:SetPos(0, -50)
    QInvBG:SetSize(QInvPnl:GetWide(), QInvPnl:GetTall())
   
    QInvBG.Paint = function(self, w, h)
        surface.SetDrawColor(ZWR.Theme.primary)
        surface.DrawRect(0, 0, w, h)
    end

    local dummyPnl = vgui.Create("DPanel", QFrame)

    QFrame.navbar:AddTab("Inventory", QInvPnl)
    QFrame.navbar:AddTab("Dummy", dummyPnl)

    QFrame.navbar:SetActive(1)

    --Set the clientQMenu to the frame, so we can remove after closing
    clientQMenu = QFrame
end

hook.Add("OnSpawnMenuOpen", "ZWR_QMenu_Open", function()
    if LocalPlayer():Alive() then
        QMenu()
    end
end)

hook.Add("OnSpawnMenuClose", "ZWR_QMenu_Close", function()
    if clientQMenu and clientQMenu:IsValid() then
        clientQMenu:Remove()
        clientQMenu = nil
    end
end)