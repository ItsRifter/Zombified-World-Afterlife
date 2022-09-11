ZWA_UISizes = {
    header = { height = 48 },
    navbar = { height = 56 },
    invSlot = { height = 64 },
    invPanel = { width = 256, height = 512 }
}

ZWA_Fonts:CreateFont("Header", 26)
ZWA_Fonts:CreateFont("Button", 20)

local closeBtnMat = Material( "zwa/ui/closeBtn.png" )

local FRAME = {}

function FRAME:Init()
    self.header = self:Add("Panel")
    self.header:Dock(TOP)
    self.header.Paint = function(pnl, w, h)
        draw.RoundedBoxEx(6, 0, 0, w, h, ZWA_Theme.TabMenu.primary, true, true, false, false)
    end

    self.header.closeBtn = self.header:Add("DButton")
    self.header.closeBtn:Dock(RIGHT)
    self.header.closeBtn.DoClick = function(pnl)
        self:Remove()
    end
    
    self.header.closeBtn.margin = 8
    self.header.closeBtn:SetText("")

    self.header.closeBtn.Paint = function(pnl, w, h)
        local margin = pnl.margin

        surface.SetDrawColor(ZWA_Theme.TabMenu.closeBtn)
        surface.SetMaterial(closeBtnMat)
        surface.DrawTexturedRect(margin, margin, w - (margin * 2), h - (margin * 2))
    end

    self.header.title = self.header:Add("DLabel")
    self.header.title:Dock(LEFT)
    self.header.title:SetFont("ZWA_Fonts.Header")
    self.header.title:SetTextColor(ZWA_Theme.TabMenu.text.h1)
    self.header.title:SetTextInset(16, 0)
end

function FRAME:SetTitle(text)
    self.header.title:SetText(text)
    self.header.title:SizeToContents()
end

function FRAME:PerformLayout(w, h)
    self.header:SetTall(ZWA_UISizes.header.height)
end

function FRAME:Paint(w, h)
    local aX, aY = self:LocalToScreen()
end

vgui.Register("ZWA_Frame", FRAME, "EditablePanel")

local NAVFRAME = {}

function NAVFRAME:Init()
    self.navbar = self:Add("ZWA_Navbar")
    self.navbar:Dock(TOP)
    self.navbar:SetBody(self)
end

function NAVFRAME:PerformLayout(w, h)
    self.BaseClass.PerformLayout(self, w, h)

    self.navbar:SetTall(ZWA_UISizes.navbar.height)
end


vgui.Register("ZWA_Frame_Navbar", NAVFRAME, "ZWA_Frame")

local NAVBAR = {}

AccessorFunc(NAVBAR, "m_body", "Body")

function NAVBAR:Init()
    self.buttons = {}
    self.panels = {}
end

function NAVBAR:AddTab(name, panel)
    local i = table.Count(self.buttons) + 1
    self.buttons[i] = self:Add("DButton")
    local btn = self.buttons[i]
    
    btn.id = i
    btn:Dock(LEFT)
    btn:DockMargin(0, 2, 0, 0)
    btn:SetText(name)
    btn:SetFont("ZWA_Fonts.Button")
    
    btn.Paint = function(pnl, w, h)
        if self.active == pnl.id then 
            surface.SetDrawColor(ZWA_Theme.TabMenu.accent)
            surface.DrawRect(0, h - 2, w, 2)
        end
    end

    btn:SizeToContentsX(32)
    btn:SetTextColor(ZWA_Theme.TabMenu.text.h2)

    btn.DoClick = function(pnl)
        self:SetActive(pnl.id)
    end

    self.panels[i] = self:GetBody():Add(panel or "DPanel")
    panel = self.panels[i]
    panel:Dock(FILL)
    panel:SetVisible(false)
end

function NAVBAR:SetActive(id)
    local btn = self.buttons[id]

    if !IsValid(btn) then return end

    local activeBtn = self.buttons[self.active]

    if IsValid(activeBtn) then
        activeBtn:SetTextColor(ZWA_Theme.TabMenu.text.h2)
        local activePanel = self.panels[self.active]

        if IsValid(activePanel) then
            activePanel:SetVisible(false)
        end
    end
   
    self.active = id

    btn:SetTextColor(ZWA_Theme.TabMenu.accent)
    local panel = self.panels[id]
    panel:SetVisible(true)
end

function NAVBAR:GetActive()
    return self.active
end

function NAVBAR:Paint(w, h)
    surface.SetDrawColor(ZWA_Theme.TabMenu.primary)
    surface.DrawRect(0, 0, w, h)

    surface.SetDrawColor(ZWA_Theme.TabMenu.secondaryLine)
    surface.DrawRect(0, 0, w, 4)
end

vgui.Register("ZWA_Navbar", NAVBAR)

local INVPANEL = {}

function INVPANEL:Init()
    self.slots = {}
    //self:Dock(LEFT)
end

function INVPANEL:AddSlot(slotID)
    self.slots[slotID] = self:Add("ZWA_InvSlot")
    return self.slots[slotID]
end

function INVPANEL:PerformLayout(w, h)
    self:SetTall(ZWA_UISizes.invPanel.height * 2)
    //self:SetWide(ZWA_UISizes.invPanel.width)
end

function INVPANEL:Paint(w, h)
    surface.SetDrawColor(ZWA_Theme.TabMenu.invPanel)
    surface.DrawRect(0, 0, w, h)
end

vgui.Register("ZWA_Panel_Inventory", INVPANEL)

local INVSLOT = {}

function INVSLOT:Init()    
    local inner = 8

    self.Paint = function(pnl, w, h)
        surface.SetDrawColor(ZWA_Theme.TabMenu.invSlot)
        surface.DrawRect(0, 0, w, h)

        surface.SetDrawColor(ZWA_Theme.TabMenu.invSlot_inner)
        surface.DrawRect(inner - 4, inner - 4, w-inner, h-inner)
    end
end

function INVSLOT:PerformLayout(w, h)
    self:SetTall(ZWA_UISizes.invSlot.height)
    self:SetWide(self:GetTall())
end

function INVSLOT:Paint(w, h)
    surface.SetDrawColor(ZWA_Theme.TabMenu.invSlot)
    surface.DrawRect(0, 0, w, h)
end

vgui.Register("ZWA_InvSlot", INVSLOT)