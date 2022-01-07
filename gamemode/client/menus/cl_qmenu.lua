local clientQMenu = nil
local lastActive = 1

function QMenu()
    
    --Base
    local QFrame = vgui.Create("ZWR_Tab")
    QFrame:SetPos(ScrW() / 8, ScrH() / 6)
    QFrame:SetSize(ScrW() / 1.35, ScrH() / 1.45)
    QFrame:SetAlpha(0)

    QFrame:AlphaTo(255, 0.1, 0, nil)
    
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

    --for k, v in pairs(LocalPlayer().Inv.Backpack)do
        for i = 1, 4 do
            --LocalPlayer().Inv.Backpack[k][i] = vgui.Create("ZWR_InvSlot", QInvBG)
            --LocalPlayer().Inv.Backpack[k][i]:SetPos((k * 60) - 50, (i * 60) + 250)
            --LocalPlayer().Inv.Backpack[k][i]:SetCoords(k, i)
        end
    --end

    local skillsPnl = vgui.Create("DPanel", QFrame)

    local skillsBG = vgui.Create("DPanel", skillsPnl)
    skillsBG:SetPos(0, -50)
    skillsBG:SetSize(QInvPnl:GetWide(), QInvPnl:GetTall())
   
    skillsBG.Paint = function(self, w, h)
        surface.SetDrawColor(ZWR.Theme.primary)
        surface.DrawRect(0, 0, w, h)
    end

    QFrame.navbar:AddTab("Inventory", QInvPnl)
    QFrame.navbar:AddTab("Skills", skillsPnl)

    QFrame.navbar:SetActive(lastActive)

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
        --Saves last active tab
        lastActive = clientQMenu.navbar:GetActiveID()

        --Removes and nullifies
        clientQMenu:Remove()
        clientQMenu = nil
    end
end)