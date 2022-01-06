function Scoreboard(shouldShow)
    if shouldShow then
        
    else
        
    end
end

hook.Add( "ScoreboardShow", "ZWR_ShowScoreboard", function()
    Scoreboard(true)
    return false
end)

hook.Add( "ScoreboardHide", "ZWR_CloseScoreboard", function()
    Scoreboard(false)
end)
