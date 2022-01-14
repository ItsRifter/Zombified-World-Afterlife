local clientQMenu = nil
local lastActive = 1

local plymeta = FindMetaTable("Player")

function plymeta:GetInvItem(x, y)
    return self.zwrInvSlot[x][y]
end

CLIENT_FACTIONS = CLIENT_FACTIONS or {}

net.Receive("ZWR_Faction_Create_Server", function()
    local factionName = net.ReadString()
    local factionOwner = net.ReadEntity()
    local inviteOnly = net.ReadBool()
    //local factionColour = net.ReadTable()
    local curPlayers = net.ReadTable()

    local updateTBL = {
        ["name"] = factionName,
        ["owner"] = factionOwner,
        ["inviteOnly"] = inviteOnly,
        //["colour"] = factionColour
        ["curPlayers"] = curPlayers
    }

    table.insert(CLIENT_FACTIONS, updateTBL) 

end)

net.Receive("ZWR_Faction_Join_Server", function()
    local factionName = net.ReadString()
    local newPlayer = net.ReadEntity()
    for i, f in pairs(CLIENT_FACTIONS) do
        if f.name == factionName then
            table.insert(f.curPlayers, newPlayer)
            PrintTable(f.curPlayers)
        end
    end
end)

net.Receive("ZWR_Faction_Discard_Server", function()
    local name = net.ReadString()
    for i, f in pairs(CLIENT_FACTIONS) do
        if f.name == name then
            table.remove(CLIENT_FACTIONS, i)
        end
    end
end)

net.Receive("ZWR_Faction_Leave_Server", function()
    local name = net.ReadString()
    local ply = net.ReadEntity()

    for _, f in pairs(CLIENT_FACTIONS) do
        if f.name == name then
            for i, p in pairs(f.curPlayers) do
                print(p:Nick())
                if p == ply then                
                    print(table.remove(f.curPlayers, i))
                    table.remove(f.curPlayers, i)
                    
                end
            end
        end
    end
end)

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
        if curName == "" then chat.AddText("Make sure you press enter to apply name") return end
        if string.len(curName) > 15 then chat.AddText("Name exceeds length limit") return end

        for _, f in pairs(CLIENT_FACTIONS) do
            if string.find(f.name, curName) then
                chat.AddText("Your name conflicts with another faction, try a different name")
                return
            end
        end

        net.Start("ZWR_Faction_Create")
            net.WriteString(curName)
            net.WriteBool(inviteOnlyTickbox:GetChecked())
                //Could have used net.WriteColor but can't figure what it wants (even with :GetColor())
                net.WriteInt(colourFaction:GetColor().r, 32)
                net.WriteInt(colourFaction:GetColor().g, 32)
                net.WriteInt(colourFaction:GetColor().b, 32)
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

    local QItemWidth = 500

    local QItemPnl = vgui.Create("DPanel", QInvPnl)
    QItemPnl:SetPos(QFrame:GetWide() - QItemWidth, 0)
    QItemPnl:SetSize(QItemWidth, 550)
    QItemPnl:SetAlpha(0)
    QItemPnl.Paint = function(self, w, h)
        surface.SetDrawColor(Color(50, 50, 50, 255))
        surface.DrawRect(0, 0, w, h)
    end

    -- for w, s in pairs(LocalPlayer().zwrInvSlot) do
    --     for h = 1, LocalPlayer():GetNWInt("ZWR_Inventory_SlotHeight") do
    --         LocalPlayer().zwrInvSlot[w][h] = vgui.Create("ZWR_InvSlot", QInvPnl)
    --     end
    -- end

    local itemScale = 1.25

    local QitemModel = vgui.Create("DModelPanel", QItemPnl)
    QitemModel:SetSize(500 * itemScale, 100 * itemScale)
    QitemModel:SetModel("")   
    function QitemModel:LayoutEntity( ent ) return end
    
    local itemName = vgui.Create("DLabel", QItemPnl)
    itemName:SetText("")
    itemName:SetFont("ZWR_QMenu_Inventory_Item_Name")
    itemName:SetPos(0, QItemPnl:GetTall() / 3)

    local itemDesc = vgui.Create("DLabel", QItemPnl)
    itemDesc:SetText("")
    itemDesc:SetFont("ZWR_QMenu_Inventory_Item_Desc")
    itemDesc:SetPos(0, 250)
    itemDesc:SizeToContents()

    local useBtn = vgui.Create("DButton", QItemPnl)
    useBtn:SetSize(64, 32)
    useBtn:SetPos(0, QItemPnl:GetTall() - useBtn:GetTall())
    useBtn:SetText("Use")

    local dropBtn = vgui.Create("DButton", QItemPnl)
    dropBtn:SetSize(64, 32)
    dropBtn:SetPos(QItemPnl:GetWide() - dropBtn:GetWide(), QItemPnl:GetTall() - useBtn:GetTall())
    dropBtn:SetText("Drop")
    
    local QInvScroll = vgui.Create("DScrollPanel", QInvPnl)
    QInvScroll:SetSize(650 * itemScale, 500 * itemScale)
    QInvScroll.panels = {}

    local QInvList = vgui.Create("DIconLayout", QInvScroll)
    QInvList:SetPos(0, 50)
    QInvList:SetSize(650, 1250)
    QInvList:SetSpaceX(1)
    QInvList:SetSpaceY(1)

    local yPadding = ScrH() * 0.001
    local xPadding = ScrW() * 0.001

    for k, v in pairs(LocalPlayer().zwrInv) do
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

        itemInvModel.DoClick = function(self)
            QItemPnl:AlphaTo(255, 0.25, 0, nil)
        
            itemName:SetText(itemData.DisplayName)
            itemName:SizeToContents()

            itemDesc:SetText(itemData.Desc)
            itemDesc:SizeToContents()

            local num = 1.25
            QitemModel:SetModel(itemData.Model)
            local min, max = QitemModel.Entity:GetRenderBounds()
            local pos = min / num + Vector(0, 20, 0)
            QitemModel.Entity:SetPos(Vector(pos / 4 - Vector(15, 0, 0), pos, pos))
            QitemModel:SetFOV(50)
        
            QitemModel:SetCamPos(Vector(20, 90, 0))
            QitemModel:SetLookAt(Vector(pos, 0, 0))

            useBtn.DoClick = function(self)
                QItemPnl:AlphaTo(0, 0.25, 0, nil)
                QitemModel:SetModel("")
                net.Start("ZWR_Inventory_UseItem")
                    net.WriteString(itemData.Name)
                net.SendToServer()
            end

            dropBtn.DoClick = function(self)
                QItemPnl:AlphaTo(0, 0.25, 0, nil)
                QitemModel:SetModel("")
                net.Start("ZWR_Inventory_DropItem")
                    net.WriteString(itemData.Name)
                net.SendToServer()
            end
        end
    end
    
    QInvScroll.OnSizeChanged = function(self, w, h)
        for i, v in pairs(self.panels) do
            i:SetTall(h * .1)
        end
    end

    net.Receive("ZWR_Inventory_Refresh_Remove", function()
        local clearItem = net.ReadString()
        table.RemoveByValue(LocalPlayer().zwrInv, clearItem)
        
        if not clientQMenu or not clientQMenu:IsValid() then return end
        QInvList:Clear()

        for k, v in pairs(LocalPlayer().zwrInv) do
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

            itemInvModel.DoClick = function(self)
                QItemPnl:AlphaTo(255, 0.25, 0, nil)
            
                itemName:SetText(itemData.DisplayName)
                itemName:SizeToContents()

                itemDesc:SetText(itemData.Desc)
                itemDesc:SizeToContents()

                local num = 1.25
                QitemModel:SetModel(itemData.Model)
                local min, max = QitemModel.Entity:GetRenderBounds()
                local pos = min / num + Vector(0, 20, 0)
                QitemModel.Entity:SetPos(Vector(pos / 4 - Vector(15, 0, 0), pos, pos))
                QitemModel:SetFOV(50)
            
                QitemModel:SetCamPos(Vector(20, 90, 0))
                QitemModel:SetLookAt(Vector(pos, 0, 0))

                useBtn.DoClick = function(self)
                    QItemPnl:AlphaTo(0, 0.25, 0, nil)
                    QitemModel:SetModel("")
                    net.Start("ZWR_Inventory_UseItem")
                        net.WriteString(itemData.Name)
                    net.SendToServer()
                end

                dropBtn.DoClick = function(self)
                    QItemPnl:AlphaTo(0, 0.25, 0, nil)
                    QitemModel:SetModel("")
                    net.Start("ZWR_Inventory_DropItem")
                        net.WriteString(itemData.Name)
                    net.SendToServer()
                end
            end
        end
    end)

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

    local factionList = vgui.Create("DIconLayout", factionsPnl)
    factionList:SetPos(0, 50)
    factionList:SetSize(750, 1250)
    factionList:SetSpaceX(1)
    factionList:SetSpaceY(1)

    for i, f in pairs(CLIENT_FACTIONS) do
        if not f.owner:IsValid() then continue end
        local factionPnl = vgui.Create("DPanel", factionList)
        factionPnl:SetSize(300, 150)

        factionPnl.Paint = function(self, w, h)
            surface.SetDrawColor(ZWR.Theme.factions.primary)
            surface.DrawRect(0, 0, w, h)
        end

        local factionName = vgui.Create("DLabel", factionPnl)
        factionName:SetText("Faction: " .. f.name)
        factionName:SetFont("ZWR_QMenu_Factions_Name")
        factionName:SetPos(0, 0)
        factionName:SizeToContents()

        local factionOwnerName = vgui.Create("DLabel", factionPnl)
        factionOwnerName:SetText("Owner: " .. f.owner:Nick())
        factionOwnerName:SetFont("ZWR_QMenu_Factions_Name")
        factionOwnerName:SetPos(0, 25)
        factionOwnerName:SizeToContents()
        
        local curPlayerLabel = vgui.Create("DLabel", factionPnl)
        curPlayerLabel:SetText("Size: " .. #f.curPlayers)
        curPlayerLabel:SetFont("ZWR_QMenu_Factions_Name")
        curPlayerLabel:SetPos(0, 50)
        curPlayerLabel:SizeToContents()

        local joinFactionBtn = vgui.Create("DButton", factionPnl)
        joinFactionBtn:SetSize(72, 48)
        joinFactionBtn:SetPos(0, factionPnl:GetTall() - joinFactionBtn:GetTall())
        joinFactionBtn:SetText("Join")

        joinFactionBtn.DoClick = function(self)
            if f.inviteOnly then
                chat.AddText("That faction is set to invite only, ask the owner to invite you")
                return
            end

            if LocalPlayer():GetNWString("ZWR_Faction") == f.name then
                chat.AddText("You are already part of this faction")
                return
            end

            if LocalPlayer():GetNWString("ZWR_Faction", "Loner") ~= "Loner" then
                chat.AddText("You are currently part of a faction, leave it before joining another")
                return
            end

            net.Start("ZWR_Faction_Join")
                net.WriteString(f.name)
            net.SendToServer()

            clientQMenu:Remove()
            clientQMenu = nil
        end

        local ownerModel = vgui.Create("SpawnIcon", factionPnl)
        ownerModel:SetModel(f.owner:GetModel())
        ownerModel:SetPos(factionPnl:GetWide() - ownerModel:GetWide(), factionPnl:GetTall() - ownerModel:GetTall())
    end

    local createFactionBtn = vgui.Create("DButton", factionsPnl)
    createFactionBtn:SetText("Create Faction")
    createFactionBtn:SetSize(128, 64)
    createFactionBtn:SetPos(factionsPnl:GetWide() - createFactionBtn:GetWide(), 0)

    createFactionBtn.DoClick = function(pnl)
        if LocalPlayer():GetNWString("ZWR_Faction", "Loner") == "Loner" then
            QMenuFactionCreation()
        end
    end

    if LocalPlayer():GetNWString("ZWR_Faction", "Loner") ~= "Loner" then
        local leaveFactionBtn = vgui.Create("DButton", factionsPnl)
        leaveFactionBtn:SetText("Leave Faction")
        leaveFactionBtn:SetSize(128, 64)
        leaveFactionBtn:SetPos(factionsPnl:GetWide() - leaveFactionBtn:GetWide(), factionsPnl:GetTall() - (leaveFactionBtn:GetTall() + 52))

        leaveFactionBtn.DoClick = function(pnl)
            local isOwnerOfFaction = nil
            for _, f in pairs(CLIENT_FACTIONS) do
                if LocalPlayer() == f.owner then
                    isOwnerOfFaction = f
                end
            end

            if isOwnerOfFaction then
                net.Start("ZWR_Faction_Discard")
                net.WriteString(isOwnerOfFaction.name)
                net.SendToServer()
            else
                net.Start("ZWR_Faction_Leave")
                net.SendToServer()
            end

            clientQMenu:Remove()
            clientQMenu = nil
        end
    end

    QFrame.navbar:AddTab("Inventory", QInvPnl)
    QFrame.navbar:AddTab("Skills", skillsPnl)
    QFrame.navbar:AddTab("Factions", factionsPnl)

    QFrame.navbar:SetActive(lastActive)
end

function IsRoomFor(item)
	for k,v in pairs(LocalPlayer().zwrInvSlot) do
		for k2, pnl in pairs(LocalPlayer().zwrInvSlot[k]) do
			if not pnl:GetItemPanel() then
				local x, y = pnl:GetCoords()
                
                local DBItem
                if GAMEMODE.DB.Items[item] then
                    DBItem = GAMEMODE.DB.Items[item]
                elseif GAMEMODE.DB.Weapons[item] then
                    DBItem = GAMEMODE.DB.Weapons[item]
                else continue end

				local itmw, itmh = DBItem.SizeX, DBItem.SizeY
				local full = false

				for i1 = x, (x + itmw) - 1 do
					if full then break end
					for i2 = y, (y + itmh) - 1 do
						if LocalPlayer():GetInvItem(i1, i2) then --check if the panels in the area are full.
							full = true
							break
						end
					end
				end
				if full then
					return pnl --If there's room then return the open panel.
				end
			end
		end
	end
	return false --if not, then return false.
end

function AddItem(item, invPnl)
	local place = IsRoomFor(item)
	if place then
		
		local itm = vgui.Create("ZWR_InvItem", invPnl)
		itm:SetItem(item)
		itm:SetPos(place:GetPos())

		local x, y = place:GetCoords()

		local DBItem
        if GAMEMODE.DB.Items[item] then
            DBItem = GAMEMODE.DB.Items[item]
        elseif GAMEMODE.DB.Weapons[item] then
            DBItem = GAMEMODE.DB.Weapons[item]
        end

        local itmw, itmh = DBItem.SizeX, DBItem.SizeY

		for i1 = x, (x + itmw) - 1 do
			for i2 = y, (y + itmh) - 1 do
				LocalPlayer():GetInvItem(i1,i2):SetItemPanel(DBItem)
			end
		end
		
		return true
		
	else
		return false
	end
end

net.Receive("ZWR_Inventory_Init", function()
    local widthSlots = net.ReadInt(32)
    local heightSlots = net.ReadInt(32)
    
    LocalPlayer().zwrInv = {}
    LocalPlayer().zwrInvSlot = {}

    for i = 1, widthSlots do
        LocalPlayer().zwrInvSlot[i] = {} 
    end

    for k, v in pairs(LocalPlayer().zwrInv)do
        for i = 1, heightSlots do
            LocalPlayer().zwrInvSlot[k][i] = false 
        end
    end
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