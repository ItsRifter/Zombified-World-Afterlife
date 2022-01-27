function InvestBaseMenu(invested, reqInvest)
    local investMenu = vgui.Create("DFrame")
    investMenu:SetTitle("")
    investMenu:SetSize(ScrW() / 2, ScrH() / 2)
    investMenu:Center()
    investMenu:MakePopup()
end

net.Receive("ZWR_FactionBase_InvestFunds_Server", function()
    local curInvested = net.ReadInt(32)
    local reqInvestment = net.ReadInt(32)

    InvestBaseMenu(curInvested, reqInvested)
end)