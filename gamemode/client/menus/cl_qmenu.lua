local clientQMenu = nil
local lastActive = 1

function QMenuFactionCreation()
    local QFFrame = vgui.Create("DFrame")
    QFFrame:SetTitle("")
    QFFrame:SetSize(ScrW() / 3.25, ScrH() / 2.65)
    QFFrame:Center()
    QFFrame:SetAlpha(0)
    QFFrame:MakePopup()
    QFFrame:SetDraggable(false)
    QFFrame:AlphaTo(255, 0.1, 0, nil)

    QFFrame.Paint = function(self, w, h)
        surface.SetDrawColor(Color(65, 65, 65, 255))
        surface.DrawRect(0, 0, w, h)
    end

    local factionNameLabel = vgui.Create("DLabel", QFFrame)
    factionNameLabel:SetText("Faction Name")
    factionNameLabel:SetFont("ZWR_QMenu_Factions")
    factionNameLabel:SetPos(74, 64)
    factionNameLabel:SizeToContents()

    local factionNameEntry = vgui.Create( "DTextEntry", QFFrame )
	factionNameEntry:SetPos(16, 92)
	factionNameEntry:SetPlaceholderText( "Put your faction name here!" )
    factionNameEntry:SetSize(256, 22)

    local inviteOnlyTickbox = vgui.Create("DCheckBoxLabel", QFFrame)
    inviteOnlyTickbox:SetPos(16, 156)
    inviteOnlyTickbox:SetSize(32, 32)
    inviteOnlyTickbox:SetFont("ZWR_QMenu_Factions")
    inviteOnlyTickbox:SetText("Invite only?")

    local colourFaction = vgui.Create("DColorMixer", QFFrame)
    colourFaction:SetPos(QFFrame:GetWide() / 2 + 25, 50)
    colourFaction:SetPalette(false) 
    colourFaction:SetAlphaBar(false)

    local previewName = vgui.Create("DLabel", QFFrame)
    previewName:SetFont("ZWR_QMenu_Factions_Preview")
    previewName:SetPos(52, QFFrame:GetTall() - 55)
    previewName:SetText(LocalPlayer():Nick())
    previewName:SizeToContents()
    previewName.Think = function(self)
        previewName:SetTextColor(colourFaction:GetColor())
    end

    local previewMessage = vgui.Create("DLabel", QFFrame)
    previewMessage:SetFont("ZWR_QMenu_Factions")
    previewMessage:SetText("This is how you will look to other players")
    previewMessage:SetPos(16, QFFrame:GetTall() - 100)
    previewMessage:SizeToContents()

    local previewAvatar = vgui.Create("AvatarImage", QFFrame)
    previewAvatar:SetSize(48, 48)
    previewAvatar:SetPos(0, QFFrame:GetTall() - 65)
    previewAvatar:SetPlayer(LocalPlayer(), 64)

    local createBtn = vgui.Create("DButton", QFFrame)
    createBtn:SetSize(108, 48)
    createBtn:SetPos(QFFrame:GetWide() / 2.45, QFFrame:GetTall() - 50)
    createBtn:SetText("Create Faction")

    local curName = ""
    factionNameEntry.OnValueChange = function(self)
        curName = self:GetValue()
    end

    createBtn.DoClick = function(self)
        if curName == "" then return end

        net.Start("ZWR_Faction_Create")
            net.WriteString(curName)
            net.WriteBool(inviteOnlyTickbox:GetChecked())
        net.SendToServer()

        QFFrame:Close()
    end
end

function QMenu()
    
    --Base
    local QFrame = vgui.Create("ZWR_Tab")
    QFrame:SetPos(ScrW() / 8, ScrH() / 6)
    QFrame:SetSize(ScrW() / 1.35, ScrH() / 1.45)
    QFrame:SetAlpha(0)

    QFrame:AlphaTo(255, 0.1, 0, nil)
    
    --Set the clientQMenu to the frame, so we can remove after closing
    clientQMenu = QFrame

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

    local QInvScroll = vgui.Create("DScrollPanel", QInvPnl)
    QInvScroll:Dock(FILL)
    QInvScroll.panels = {}

    local QInvList = vgui.Create("DIconLayout", QInvScroll)
    QInvList:SetPos(0, 50)
    QInvList:SetSize(1000, 1500)
    QInvList:SetSpaceX(10)
    QInvList:SetSpaceY(15)

    local yPadding = ScrH() * 0.001
    local xPadding = ScrW() * 0.001

    if not LocalPlayer().zwrInv then
        LocalPlayer().zwrInv = {}
    end

    for k, v in pairs(LocalPlayer().zwrInv)do

        local itemData

        if GAMEMODE.DB.Items[v] then
            itemData = GAMEMODE.DB.Items[v]
        elseif GAMEMODE.DB.Weapons[v] then
            itemData = GAMEMODE.DB.Weapons[v]
        else continue end
        
        local invItem = QInvList:Add("DPanel")
        invItem:SetSize(64 * itemData.SizeX, 64 * itemData.SizeY)
        
        invItem:DockMargin(xPadding, yPadding, 0, 0)

        invItem.Paint = function(self, w, h)
            surface.SetDrawColor(Color(0, 0, 0, 165))
            surface.DrawRect(0, 0, w, h)
            draw.SimpleText(itemData.DisplayName , "ZWR_QMenu_Inventory_Item", w * 0.05, h * .1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        QInvScroll.panels[invItem] = true

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
        
        local optionIsOpen = false

        local itemOptionBox = vgui.Create( "DComboBox", itemInvModel )
        itemOptionBox:SetPos(0, invItem:GetTall())
        itemOptionBox:SetSize( 100, 20 )
        itemOptionBox:SetValue( "" )
        itemOptionBox:AddChoice( "Drop" )
        itemOptionBox:AddChoice( "Use" )
        itemOptionBox:SetAlpha(0) 
        
        itemOptionBox.OnSelect = function( self, index, value )
            if value == "Use" then
                net.Start("ZWR_Inventory_UseItem")
                    net.WriteString(itemData.Name)
                net.SendToServer()
            end

            if value == "Drop" then
                net.Start("ZWR_Inventory_DropItem")
                    net.WriteString(itemData.Name)
                net.SendToServer()

                table.RemoveByValue(LocalPlayer().zwrInv, itemData.Name)

                QFrame:Remove()
                clientQMenu = nil
            end
        end
        itemInvModel.DoClick = function(self)
            if !optionIsOpen then
                optionIsOpen = true
                itemOptionBox:SetAlpha(255)
                itemOptionBox:OpenMenu()
            elseif optionIsOpen then
                optionIsOpen = false
                itemOptionBox:SetAlpha(0)
                itemOptionBox:CloseMenu()
            end
        end
    end

    QInvScroll.OnSizeChanged = function(self, w, h)
        for i, v in pairs(self.panels) do
            i:SetTall(h * .1)
        end
    end

    local skillsPnl = vgui.Create("DPanel", QFrame)

    local skillsBG = vgui.Create("DPanel", skillsPnl)
    skillsBG:SetPos(0, -50)
    skillsBG:SetSize(QInvPnl:GetWide(), QInvPnl:GetTall())
   
    skillsBG.Paint = function(self, w, h)
        surface.SetDrawColor(ZWR.Theme.primary)
        surface.DrawRect(0, 0, w, h)
    end

    local factionsPnl = vgui.Create("DPanel", QFrame)
    factionsPnl:SetSize(QFrame:GetWide(), 600)

    local factionsBG = vgui.Create("DPanel", factionsPnl)
    factionsBG:SetPos(0, -50)
    factionsBG:SetSize(QInvPnl:GetWide(), QInvPnl:GetTall())
   
    factionsBG.Paint = function(self, w, h)
        surface.SetDrawColor(ZWR.Theme.primary)
        surface.DrawRect(0, 0, w, h)
    end

    local createFactionBtn = vgui.Create("DButton", factionsPnl)
    createFactionBtn:SetText("Create Faction")
    createFactionBtn:SetSize(128, 64)
    createFactionBtn:SetPos(factionsPnl:GetWide() - 128, 0)

    createFactionBtn.DoClick = function(pnl)
        QMenuFactionCreation()
    end

    QFrame.navbar:AddTab("Inventory", QInvPnl)
    QFrame.navbar:AddTab("Skills", skillsPnl)
    QFrame.navbar:AddTab("Factions", factionsPnl)

    QFrame.navbar:SetActive(lastActive)
end

net.Receive("ZWR_Inventory_Init", function()
    LocalPlayer().zwrInv = {}
end)

net.Receive("ZWR_Inventory_UpdateItem", function()
    local itemName = net.ReadString()

    if not LocalPlayer().zwrInv then return end

    table.insert(LocalPlayer().zwrInv, itemName)
end)

hook.Add("OnSpawnMenuOpen", "ZWR_QMenu_Open", function()
    if LocalPlayer():Alive() then
        QMenu()
    end
end)

hook.Add("OnSpawnMenuClose", "ZWR_QMenu_Close", function()
    if clientQMenu and clientQMenu:IsValid() then
        --Saves last active tab
        lastActive = clientQMenu.navbar:GetActiveID()
        shouldBeOpen = false
        --Removes and nullifies
        clientQMenu:Remove()
        clientQMenu = nil
    end
end)