--Time in seconds till a switch in cycle
local timeUntilNight = 300
local timeUntilDay = 600

server_cycleTime = 0

server_isDayTime = false
server_isNightTime = true

local server_shouldSend = true

hook.Add("Think", "ZWR_CycleThink", function()
    if GetConVar("zwr_cycle_enabled"):GetInt() == 0 then
        if server_shouldSend then
            for _, v in ipairs(player.GetAll()) do
                v:SetNWBool("ZWR_Time_Enable", false)
            end
            server_shouldSend = false
        end
        return 
    else
        if not server_shouldSend then
            for _, v in ipairs(player.GetAll()) do
                v:SetNWBool("ZWR_Time_Enable", true)
            end
            BeginDayCycle()
            server_shouldSend = true
        end
    end
    
    if server_cycleTime < CurTime() and server_isDayTime then
        BeginNightCycle()
    elseif server_cycleTime < CurTime() and server_isNightTime then
        BeginDayCycle()
    end
end)

function BeginNightCycle()
    server_isDayTime = false
    server_isNightTime = true

    BroadcastSound("zwr/nightfall.wav")

    server_cycleTime = timeUntilDay + CurTime()

    for _, v in ipairs(player.GetAll()) do
        v:SetNWInt("ZWR_Time", server_cycleTime)
        v:SetNWBool("ZWR_Time_IsInvasion", server_isNightTime)
    end
end

function BeginDayCycle()
    server_isDayTime = true
    server_isNightTime = false
    
    --BroadcastSound("/music/ravenholm_1.mp3")

    server_cycleTime = timeUntilNight + CurTime()

    for _, v in ipairs(player.GetAll()) do
        v:SetNWInt("ZWR_Time", server_cycleTime)
        v:SetNWBool("ZWR_Time_IsInvasion", server_isNightTime)
    end

end

concommand.Add("zwr_togglecycle", function(ply)
    if not ply:IsAdmin() then return end

    if server_isDayTime then
        BeginNightCycle()
    elseif server_isNightTime then
        BeginDayCycle()
    end
end)

concommand.Add("zwr_getcycle", function(ply)
    if not ply:IsAdmin() then return end

    if server_isDayTime then
        ply:PrintMessage(HUD_PRINTCONSOLE, "Day")
    elseif server_isNightTime then
        ply:PrintMessage(HUD_PRINTCONSOLE, "Night")
    end
end)