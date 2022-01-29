local scoreboardPanel

function Scoreboard(shouldShow)
    if shouldShow then
        local scoreFrame = vgui.Create("DFrame")
        scoreFrame:SetSize(ScrW() / 1.5, ScrH() / 1.5)
        scoreFrame:SetPos(ScrW() / 6, ScrH() / 12)
        scoreFrame:ShowCloseButton(false)
        scoreFrame:SetTitle("")

        scoreFrame:SetAlpha(0)

        scoreFrame:AlphaTo(255, 0.1, 0, nil)

        scoreFrame.Paint = function(self, w, h)
            surface.SetDrawColor(ZWR.Theme.scoreboard.primary)
            surface.DrawRect(0, 0, w, h)
        end
        
        local curPlayers = vgui.Create("DPanel", scoreFrame)
        curPlayers:SetPos(0, 125)
        curPlayers:SetSize(scoreFrame:GetWide(), scoreFrame:GetTall())
        
        curPlayers.Paint = function(self, w, h) 
            surface.SetDrawColor(ZWR.Theme.scoreboard.secondary)
            surface.DrawRect(0, 0, w, h)
        end

        local scoreScroll = vgui.Create( "DScrollPanel", curPlayers ) 
        scoreScroll:Dock( FILL )

        local playerList = vgui.Create("DIconLayout", scoreScroll)
        playerList:SetSize(curPlayers:GetWide(), curPlayers:GetTall())
        playerList:SetPos(0, 25)
        playerList:SetSpaceX(16)
        playerList:SetSpaceY(25)

        for i, v in ipairs(player.GetAll()) do
            local playerPnl = vgui.Create("DPanel", playerList)
            playerPnl:SetSize(200, 100)

            playerPnl.Paint = function(self, w, h)
                surface.SetDrawColor(ZWR.Theme.scoreboard.playerPanel)
                surface.DrawRect(0, 0, w, h)
            end
            
            local profile = vgui.Create("AvatarImage", playerPnl)
            profile:SetSize( 48, 48 )
            profile:SetPos( 0, 0 )
            
            if not v:IsBot() then
                profile:SetPlayer( v , 64 )
            end

            local name = vgui.Create("DLabel", playerPnl)
            name:SetFont("ZWR_Scoreboard_Nickname")
            name:SetText(v:Nick())
            name:SizeToContents()
            name:SetPos(50, 0)

            local curFaction = vgui.Create("DLabel", playerPnl)
            curFaction:SetPos(0, 50)
            curFaction:SetText("Faction: " .. v:GetNWString("ZWR_Faction", "Loner"))
            curFaction:SetFont("ZWR_Scoreboard_Stats")
            curFaction:SizeToContents()

            local level = vgui.Create("DLabel", playerPnl)
            level:SetPos(0, 75)
            level:SetText("Level: " ..  v:GetNWInt("ZWR_Level", -1))
            level:SetFont("ZWR_Scoreboard_Stats")

        end

        scoreboardPanel = scoreFrame
    else
        if scoreboardPanel and scoreboardPanel:IsValid() then
            scoreboardPanel:Close()
            scoreboardPanel = nil
        end
    end
end

hook.Add( "ScoreboardShow", "ZWR_ShowScoreboard", function()
    Scoreboard(true)
    return false
end)

hook.Add( "ScoreboardHide", "ZWR_CloseScoreboard", function()
    Scoreboard(false)
end)
