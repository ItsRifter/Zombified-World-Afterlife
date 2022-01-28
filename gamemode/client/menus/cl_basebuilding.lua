function InvestBaseMenu(invested, reqInvest)
    
    local investMenu = vgui.Create("DFrame")
    investMenu:SetTitle("")
    investMenu:SetSize(ScrW() / 4, ScrH() / 4)
    investMenu:Center()
    investMenu:SetDraggable(false)
    investMenu:MakePopup()

    local investSlider = vgui.Create("DNumSlider", investMenu)
    investSlider:SetText("Invest")
    investSlider:SetPos(50, 75)
    investSlider:SetSize( 300, 100 )
    investSlider:SetMin( invested )
    investSlider:SetMax( reqInvest )
    investSlider:SetDecimals(0)
    investSlider:SetDefaultValue(0)
    
    local submitFundsBtn = vgui.Create("DButton", investMenu)
    submitFundsBtn:SetText("Submit Funding")
    submitFundsBtn:SetSize(92, 48)
    submitFundsBtn:SetPos(investMenu:GetWide() / 2.5, 175)

    submitFundsBtn.DoClick = function()
        net.Start("ZWR_FactionBase_InvestFunds")
            net.WriteInt(investSlider:GetRange(), 32)
        net.SendToServer()
        
        investMenu:Close()
    end
end

net.Receive("ZWR_FactionBase_InvestFunds_Server", function()
    local curInvested = net.ReadInt(32)
    local reqInvestment = net.ReadInt(32)

    InvestBaseMenu(curInvested, reqInvestment)
end)