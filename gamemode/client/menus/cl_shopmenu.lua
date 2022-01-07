
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
end

net.Receive("ZWR_OpenShop", function()
    local type = net.ReadString()
    
    if type == "weapon" then
        OpenWeaponsShop()
    end

end)