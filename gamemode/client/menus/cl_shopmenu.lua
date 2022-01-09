
function OpenWeaponsShop()
    local wepShopFrame = vgui.Create("DFrame")
    wepShopFrame:SetSize(ScrW() / 1.5, ScrH() / 1.5)
    wepShopFrame:Center()
    wepShopFrame:SetTitle("")
    wepShopFrame:MakePopup()

    wepShopFrame.Paint = function(self, w, h)
        surface.SetDrawColor(ZWR.Theme.shop.primary)
        surface.DrawRect(0, 0, w, h)
    end
    
    local curCash = LocalPlayer():GetNWInt("ZWR_Cash")

    local curCashLabel = vgui.Create("DLabel", wepShopFrame)
    curCashLabel:SetText("Cash: " .. curCash)
    curCashLabel:SetFont("ZWR_Shop_CurrentCash")
    curCashLabel:SetPos(10, 10)
    curCashLabel:SizeToContents()

    local weaponsScroll = vgui.Create( "DScrollPanel", wepShopFrame ) 
    weaponsScroll:Dock( FILL )

    local weaponsList = vgui.Create("DIconLayout", weaponsScroll)
    weaponsList:SetPos(0, 50)
    weaponsList:SetSize(wepShopFrame:GetWide(), wepShopFrame:GetTall())
    weaponsList:SetSpaceX(10)
    weaponsList:SetSpaceY(15)

    for i, w in pairs(GAMEMODE.DB.Weapons) do

        local wepPanel = weaponsList:Add("DPanel")
        wepPanel:SetSize(250, 150)
        wepPanel.Paint = function(self, w, h) 
            surface.SetDrawColor(ZWR.Theme.shop.primary)
            surface.DrawRect(0, 0, w, h)
        end

        local wepModel = vgui.Create("DModelPanel", wepPanel)
        wepModel:SetSize(wepPanel:GetWide() / 2 + 175, wepPanel:GetTall() + 350)
        wepModel:SetModel(w.Model)
        wepModel:SetLookAt(Vector(0, -10, -40))
        wepModel:SetCamPos(Vector(0, 45, -35))

        local wepLabel = vgui.Create("DLabel", wepPanel)
        wepLabel:SetPos(0, wepPanel:GetTall() - 55)
        wepLabel:SetFont("ZWR_Shop_Stats_Weapon")
        wepLabel:SetText(w.DisplayName .. "\nCost: " .. w.Cost)
        wepLabel:SizeToContents()

        function wepModel:LayoutEntity(ent)
            ent:SetPlaybackRate(0)    
        end

        wepModel.DoClick = function()
            if curCash < w.Cost then return end
            
            if LocalPlayer():HasWeapon(w.Class) then return end

            net.Start("ZWR_BuyItem")
                net.WriteString("weapon")
                net.WriteString(w.Class)
                net.WriteString(w.Name)
            net.SendToServer()
            
            curCash = curCash - w.Cost
            curCashLabel:SetText("Cash: " .. curCash)
        end
    end

    for i, w in pairs(GAMEMODE.DB.Items) do

        local itemPanel = weaponsList:Add("DPanel")
        itemPanel:SetSize(250, 150)
        itemPanel.Paint = function(self, w, h) 
            surface.SetDrawColor(ZWR.Theme.shop.primary)
            surface.DrawRect(0, 0, w, h)
        end

        local itemModel = vgui.Create("DModelPanel", itemPanel)
        itemModel:SetSize(itemPanel:GetWide() / 2 + 175, itemPanel:GetTall() + 350)
        itemModel:SetModel(w.Model)
        itemModel:SetLookAt(Vector(0, -10, -40))
        itemModel:SetCamPos(Vector(0, 45, -35))

        local itemLabel = vgui.Create("DLabel", itemPanel)
        itemLabel:SetPos(0, itemPanel:GetTall() - 55)
        itemLabel:SetFont("ZWR_Shop_Stats_Ammo")
        itemLabel:SetText(w.DisplayName .. "\nCost: " .. w.Cost)
        itemLabel:SizeToContents()

        function itemModel:LayoutEntity(ent)
            ent:SetPlaybackRate(0)    
        end
        
        itemModel.DoClick = function()

            if curCash < w.Cost then return end
            
            net.Start("ZWR_BuyItem")
                net.WriteString("ammo")
                net.WriteString("")
                net.WriteString(w.Name)
            net.SendToServer()

            curCash = curCash - w.Cost
            curCashLabel:SetText("Cash: " .. curCash)
        end
    end
end

net.Receive("ZWR_OpenShop", function()
    local type = net.ReadString()
    
    if type == "weapon" then
        OpenWeaponsShop()
    end

end)