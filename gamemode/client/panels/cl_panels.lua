ZWR = {}

ZWR.Theme = {
	primary = Color(60, 50, 50),
	secondary = Color(40, 30, 30),
	background = Color(100, 100, 100, 150),
	
    invSlot = Color(25, 25, 25, 255),

    text = {
		h1 = Color(225, 225, 225),
	},
}

ZWR.UISizes = {
	header = {height = 0},
	navbar = {height = 56},
}

local PANEL = {}

function PANEL:Init()
	self.header = self:Add("Panel")
	self.header:Dock(TOP)
	
	self.header.paint = function(self, w, h)
		draw.RoundedBoxEx(6, 0, 0, w, h, ZWR.Theme.primary, true, true, false, false)
	end
	
	self.header:SetMouseInputEnabled(true)
	self.header:MakePopup()
end

function PANEL:PerformLayout(w, h)
	self.header:SetTall(ZWR.UISizes.header.height)
end

vgui.Register("ZWR_Frame", PANEL, "EditablePanel")

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
	btn:DockPadding(40, 30, 20, 10)
	btn:SetText(name)
	btn:SetFont("ZWR_QMenu_ButtonText")
	btn:SetTextColor(Color(255, 255, 255, 255))
	
	btn.Paint = function(pnl, w, h)
		if self.active == pnl.id then
			surface.SetDrawColor(ZWR.Theme.text.h1)
			surface.DrawRect(0, h - 2, w, 2)
		end
	end
	
	btn:SizeToContentsX(32)
	
	btn.DoClick = function(pnl)
		if self.active == pnl.id then return end
		self:SetActive(pnl.id)
		surface.PlaySound("buttons/combine_button7.wav")
	end

	self.panels[i] = self:GetBody():Add(panel or "DPanel")
	panel = self.panels[i]
	panel:Dock(FILL)
	panel:SetVisible(false)
	panel.Paint = nil
end

function NAVBAR:GetActive()
	return self.panels[self.active]
end

function NAVBAR:SetActive(id)
	local btn = self.buttons[id]
	if !IsValid(btn) then return end
	
	local activePnl = self.panels[self.active]
	if IsValid(activePnl) then
		activePnl:SetVisible(false)
	end
	
	local panel = self.panels[id]
	panel:SetVisible(true)
	
	self.active = id
	
end

function NAVBAR:Paint(w, h)
	surface.SetDrawColor(ZWR.Theme.secondary)
	surface.DrawRect(0, 0, w, h)
end

vgui.Register("ZWR_Navigation", NAVBAR)

local PANEL = {}

function PANEL:Init()
	self.navbar = self:Add("ZWR_Navigation")
	self.navbar:Dock(TOP)
	self.navbar:SetBody(self)
end

function PANEL:PerformLayout(w, h)
	self.BaseClass.PerformLayout(self, w, h)
	
	self.navbar:SetTall(ZWR.UISizes.navbar.height)
end

vgui.Register("ZWR_Tab", PANEL, "ZWR_Frame")

local INV_SLOT = {}

function INV_SLOT:Init()
	self.header = self:Add("Panel")
	self.header:Dock(TOP)
	
	self.header.paint = function(self, w, h)
		draw.RoundedBox(6, 0, 0, w, h, ZWR.Theme.invSlot)
	end
	
	self.header:SetMouseInputEnabled(true)
	self.header:MakePopup()
end

function INV_SLOT:PerformLayout(w, h)
	self.header:SetTall(ZWR.UISizes.header.height)
end

vgui.Register("ZWR_InvSlot", INV_SLOT, "EditablePanel")