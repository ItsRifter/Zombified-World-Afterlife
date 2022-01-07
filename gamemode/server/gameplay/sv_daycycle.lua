--Time in seconds till a switch in cycle
local timeUntilNight = 360
local timeUntilDay = 720

local cycleTime = 0

isDayTime = false
isNightTime = true

hook.Add("Think", "ZWR_CycleThink", function()
    if cycleTime < CurTime() and isDayTime then
        BeginNightCycle()
    elseif cycleTime < CurTime() and isNightTime then
        BeginDayCycle()
    end
end)

function BeginNightCycle()
    isDayTime = false
    isNightTime = true

    BroadcastSound("zwr/nightfall.wav")

    cycleTime = timeUntilDay + CurTime()
end

function BeginDayCycle()
    isDayTime = true
    isNightTime = false
    
    --BroadcastSound("/music/ravenholm_1.mp3")

    cycleTime = timeUntilNight + CurTime()
end

concommand.Add("zwr_togglecycle", function(ply)
    if not ply:IsAdmin() then return end

    if isDayTime then
        BeginNightCycle()
    elseif isNightTime then
        BeginDayCycle()
    end
end)

concommand.Add("zwr_getcycle", function(ply)
    if not ply:IsAdmin() then return end

    if isDayTime then
        ply:PrintMessage(HUD_PRINTCONSOLE, "Day")
    elseif isNightTime then
        ply:PrintMessage(HUD_PRINTCONSOLE, "Night")
    end
end)