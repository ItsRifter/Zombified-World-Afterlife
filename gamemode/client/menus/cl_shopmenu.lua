local curInvFrame
local curShopFrame

function OpenPlayerInventory()
    local invFrame = vgui.Create("DFrame")
    invFrame:SetSize(750, ScrH() / 1.5)
    invFrame:SetPos(25, ScrH() / 8)
    invFrame:SetTitle("")
    invFrame:MakePopup()

    invFrame.Paint = function(self, w, h)
        surface.SetDrawColor(ZWR.Theme.shop.primary)
        surface.DrawRect(0, 0, w, h)
    end

    invFrame.OnClose = function(self)
        if curShopFrame:IsValid() then
            curShopFrame:Close()
            curShopFrame = nil
        end
    end

    curInvFrame = invFrame

    local InvScroll = vgui.Create("DScrollPanel", invFrame)
    InvScroll:Dock(FILL)
    InvScroll.panels = {}

    local InvList = vgui.Create("DIconLayout", InvScroll)
    InvList:SetPos(0, 50)
    InvList:SetSize(1000, 1500)
    InvList:SetSpaceX(10)
    InvList:SetSpaceY(15)

    if not LocalPlayer().zwrInv then
        LocalPlayer().zwrInv = {}
    end

    local yPadding = ScrH() * 0.001
    local xPadding = ScrW() * 0.001

    for k, v in pairs(LocalPlayer().zwrInv) do

        local itemData

        if GAMEMODE.DB.Items[v] then
            itemData = GAMEMODE.DB.Items[v]
        elseif GAMEMODE.DB.Weapons[v] then
            itemData = GAMEMODE.DB.Weapons[v]
        end
        
        local invItem = InvList:Add("DPanel")
        invItem:SetSize(64 * itemData.SizeX, 64 * itemData.SizeY)
        
        invItem:DockMargin(xPadding, yPadding, 0, 0)

        invItem.Paint = function(self, w, h)
            surface.SetDrawColor(Color(0, 0, 0, 165))
            surface.DrawRect(0, 0, w, h)
            draw.SimpleText(itemData.DisplayName , "ZWR_QMenu_Inventory_Item", w * 0.05, h * .1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        InvScroll.panels[invItem] = true

        local itemInvModel = vgui.Create("DModelPanel", invItem)
        itemInvModel:SetSize(invItem:GetWide(), invItem:GetTall())
        itemInvModel:SetModel(itemData.Model)
        itemInvModel.Entity:SetPos(itemInvModel.Entity:GetPos() - Vector(-15, 10, 4))
        itemInvModel:SetFOV(50)
        local num = 0.7
        local min, max = itemInvModel.Entity:GetRenderBounds()
        itemInvModel:SetCamPos(min:Distance(max) * Vector(num, num, num))
        itemInvModel:SetLookAt((max + min) / 2)
        
        function itemInvModel:LayoutEntity( ent ) return end

        itemInvModel.DoClick = function(self)
            net.Start("ZWR_SellItem")
                net.WriteString(itemData.Name)
            net.SendToServer()
        end
    end

    --Theres probably an easier way but this works for now
    net.Receive("ZWR_Inventory_Refresh_Add", function()
        InvScroll:Clear()
        local InvList = vgui.Create("DIconLayout", InvScroll)
        InvList:SetPos(0, 50)
        InvList:SetSize(1000, 1500)
        InvList:SetSpaceX(10)
        InvList:SetSpaceY(15)

        if not LocalPlayer().zwrInv then
            LocalPlayer().zwrInv = {}
        end

        local yPadding = ScrH() * 0.001
        local xPadding = ScrW() * 0.001

        for k, v in pairs(LocalPlayer().zwrInv) do

            local itemData

            if GAMEMODE.DB.Items[v] then
                itemData = GAMEMODE.DB.Items[v]
            elseif GAMEMODE.DB.Weapons[v] then
                itemData = GAMEMODE.DB.Weapons[v]
            end
            
            local invItem = InvList:Add("DPanel")
            invItem:SetSize(64 * itemData.SizeX, 64 * itemData.SizeY)
            
            invItem:DockMargin(xPadding, yPadding, 0, 0)

            invItem.Paint = function(self, w, h)
                surface.SetDrawColor(Color(0, 0, 0, 165))
                surface.DrawRect(0, 0, w, h)
                draw.SimpleText(itemData.DisplayName , "ZWR_QMenu_Inventory_Item", w * 0.05, h * .1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            InvScroll.panels[invItem] = true

            local itemInvModel = vgui.Create("DModelPanel", invItem)
            itemInvModel:SetSize(invItem:GetWide(), invItem:GetTall())
            itemInvModel:SetModel(itemData.Model)
            itemInvModel.Entity:SetPos(itemInvModel.Entity:GetPos() - Vector(-15, 10, 4))
            itemInvModel:SetFOV(50)
            local num = 0.7
            local min, max = itemInvModel.Entity:GetRenderBounds()
            itemInvModel:SetCamPos(min:Distance(max) * Vector(num, num, num))
            itemInvModel:SetLookAt((max + min) / 2)
            
            function itemInvModel:LayoutEntity( ent ) return end

            itemInvModel.DoClick = function(self)
                net.Start("ZWR_SellItem")
                    net.WriteString(itemData.Name)
                net.SendToServer()
            end
        end
    end)

    net.Receive("ZWR_Inventory_Refresh_Remove", function()

        local clearItem = net.ReadString()
        table.RemoveByValue(LocalPlayer().zwrInv, clearItem)

        InvScroll:Clear()
        local InvList = vgui.Create("DIconLayout", InvScroll)
        InvList:SetPos(0, 50)
        InvList:SetSize(1000, 1500)
        InvList:SetSpaceX(10)
        InvList:SetSpaceY(15)

        if not LocalPlayer().zwrInv then
            LocalPlayer().zwrInv = {}
        end

        local yPadding = ScrH() * 0.001
        local xPadding = ScrW() * 0.001

        for k, v in pairs(LocalPlayer().zwrInv) do

            local itemData

            if GAMEMODE.DB.Items[v] then
                itemData = GAMEMODE.DB.Items[v]
            elseif GAMEMODE.DB.Weapons[v] then
                itemData = GAMEMODE.DB.Weapons[v]
            end
            
            local invItem = InvList:Add("DPanel")
            invItem:SetSize(64 * itemData.SizeX, 64 * itemData.SizeY)
            
            invItem:DockMargin(xPadding, yPadding, 0, 0)

            invItem.Paint = function(self, w, h)
                surface.SetDrawColor(Color(0, 0, 0, 165))
                surface.DrawRect(0, 0, w, h)
                draw.SimpleText(itemData.DisplayName , "ZWR_QMenu_Inventory_Item", w * 0.05, h * .1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            InvScroll.panels[invItem] = true

            local itemInvModel = vgui.Create("DModelPanel", invItem)
            itemInvModel:SetSize(invItem:GetWide(), invItem:GetTall())
            itemInvModel:SetModel(itemData.Model)
            itemInvModel.Entity:SetPos(itemInvModel.Entity:GetPos() - Vector(-15, 10, 4))
            itemInvModel:SetFOV(50)
            local num = 0.7
            local min, max = itemInvModel.Entity:GetRenderBounds()
            itemInvModel:SetCamPos(min:Distance(max) * Vector(num, num, num))
            itemInvModel:SetLookAt((max + min) / 2)
            
            function itemInvModel:LayoutEntity( ent ) return end

            itemInvModel.DoClick = function(self)
                net.Start("ZWR_SellItem")
                    net.WriteString(itemData.Name)
                net.SendToServer()
            end
        end
    end)
end

function OpenWeaponsShop()
    local wepShopFrame = vgui.Create("DFrame")
    wepShopFrame:SetSize(775, ScrH() / 1.5)
    wepShopFrame:SetPos(ScrW() / 1.7, ScrH() / 8)
    wepShopFrame:SetTitle("")
    wepShopFrame:SetDraggable(false)
    wepShopFrame:MakePopup()

    curShopFrame = wepShopFrame

    wepShopFrame.OnClose = function(self)
        if curInvFrame:IsValid() then
            curInvFrame:Close()
            curInvFrame = nil
        end
    end

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
            surface.SetDrawColor(Color(0, 0, 0, 165))
            surface.DrawRect(0, 0, w, h)
        end

        local wepModel = vgui.Create("DModelPanel", wepPanel)
        wepModel:SetModel(w.Model)
        wepModel:SetSize(250, 150)
        wepModel.Entity:SetPos(wepModel.Entity:GetPos() - Vector(12, 0, 4))
        wepModel:SetFOV(50)
        local num = 0.6
        local min, max = wepModel.Entity:GetRenderBounds()
        wepModel:SetCamPos(min:Distance(max) * Vector(num, num, num))
        wepModel:SetLookAt((max + min) / 2)
        
        function wepModel:LayoutEntity( ent ) return end

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
                net.WriteString(w.Name)
            net.SendToServer()
            
            curCash = curCash - w.Cost
            curCashLabel:SetText("Cash: " .. curCash)
        end
    end

    for i, w in pairs(GAMEMODE.DB.Items) do
        
        --Weapon shops shouldn't contain materials
        if string.find(w.Name, "mat") then continue end

        local itemPanel = weaponsList:Add("DPanel")
        itemPanel:SetSize(250, 150)
        itemPanel.Paint = function(self, w, h) 
            surface.SetDrawColor(Color(0, 0, 0, 165))
            surface.DrawRect(0, 0, w, h)
        end

        local itemModel = vgui.Create("DModelPanel", itemPanel)
        itemModel:SetSize(250, 150)
        itemModel:SetModel(w.Model)
        itemModel.Entity:SetPos(itemModel.Entity:GetPos() - Vector(12, 0, 4))
        itemModel:SetFOV(50)
        local num = 1.2
        local min, max = itemModel.Entity:GetRenderBounds()
        itemModel:SetCamPos(min:Distance(max) * Vector(num, num, num))
        itemModel:SetLookAt((max + min) / 2)
        
        function itemModel:LayoutEntity( ent ) return end

        local itemLabel = vgui.Create("DLabel", itemPanel)
        itemLabel:SetPos(0, itemPanel:GetTall() - 55)
        itemLabel:SetFont("ZWR_Shop_Stats_Ammo")
        itemLabel:SetText(w.DisplayName .. "\nCost: " .. w.Cost)
        itemLabel:SizeToContents()

        function itemModel:LayoutEntity(ent) return end
        
        itemModel.DoClick = function()

            if curCash < w.Cost then return end
            
            net.Start("ZWR_BuyItem")
                net.WriteString(w.Name)
            net.SendToServer()

            curCash = curCash - w.Cost
            curCashLabel:SetText("Cash: " .. curCash)
        end
    end

    net.Receive("ZWR_Shop_UpdateCash", function()
        curCash = LocalPlayer():GetNWInt("ZWR_Cash")
        curCashLabel:SetText("Cash: " .. curCash)
        curCashLabel:SizeToContents()
    end)
end

function OpenToolShop()
    local toolShopFrame = vgui.Create("DFrame")
    toolShopFrame:SetSize(775, ScrH() / 1.5)
    toolShopFrame:SetPos(ScrW() / 1.7, ScrH() / 8)
    toolShopFrame:SetTitle("")
    toolShopFrame:SetDraggable(false)
    toolShopFrame:MakePopup()

    curShopFrame = toolShopFrame

    toolShopFrame.OnClose = function(self)
        if curInvFrame:IsValid() then
            curInvFrame:Close()
            curInvFrame = nil
        end
    end

    toolShopFrame.Paint = function(self, w, h)
        surface.SetDrawColor(ZWR.Theme.shop.primary)
        surface.DrawRect(0, 0, w, h)
    end
    
    local curCash = LocalPlayer():GetNWInt("ZWR_Cash")

    local curCashLabel = vgui.Create("DLabel", toolShopFrame)
    curCashLabel:SetText("Cash: " .. curCash)
    curCashLabel:SetFont("ZWR_Shop_CurrentCash")
    curCashLabel:SetPos(10, 10)
    curCashLabel:SizeToContents()

    local toolScroll = vgui.Create( "DScrollPanel", toolShopFrame ) 
    toolScroll:Dock( FILL )

    local toolsList = vgui.Create("DIconLayout", toolScroll)
    toolsList:SetPos(0, 50)
    toolsList:SetSize(toolShopFrame:GetWide(), toolShopFrame:GetTall())
    toolsList:SetSpaceX(10)
    toolsList:SetSpaceY(15)

    for i, w in pairs(GAMEMODE.DB.Items) do
        
        --Tool shop shouldn't have weapons/ammo
        if string.find(w.Name, "weapon") or string.find(w.Name, "ammo") then continue end

        local itemPanel = toolsList:Add("DPanel")
        itemPanel:SetSize(250, 150)
        itemPanel.Paint = function(self, w, h) 
            surface.SetDrawColor(ZWR.Theme.shop.primary)
            surface.DrawRect(0, 0, w, h)
        end

        local itemModel = vgui.Create("DModelPanel", itemPanel)
        itemModel:SetSize(250, 150)
        itemModel:SetModel(w.Model)
        itemModel.Entity:SetPos(itemModel.Entity:GetPos() - Vector(12, 0, 4))
        itemModel:SetFOV(50)
        local num = 1.2
        local min, max = itemModel.Entity:GetRenderBounds()
        itemModel:SetCamPos(min:Distance(max) * Vector(num, num, num))
        itemModel:SetLookAt((max + min) / 2)
        
        function itemModel:LayoutEntity( ent ) return end

        local itemLabel = vgui.Create("DLabel", itemPanel)
        itemLabel:SetPos(0, itemPanel:GetTall() - 55)
        itemLabel:SetFont("ZWR_Shop_Stats_Ammo")
        itemLabel:SetText(w.DisplayName .. "\nCost: " .. w.Cost)
        itemLabel:SizeToContents()

        function itemModel:LayoutEntity(ent) return end
        
        itemModel.DoClick = function()

            if curCash < w.Cost then return end
           
            net.Start("ZWR_BuyItem")
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
    elseif type == "tool" then
        OpenToolShop()
    end

    OpenPlayerInventory()

end)