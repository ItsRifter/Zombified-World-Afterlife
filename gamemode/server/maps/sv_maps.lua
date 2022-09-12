ZWA_Maps = {
    ["zw_coast_v3"] = {
        [1] = {
            [1] = Vector(-9111, -5877, 490),
            [2] = Vector(-7858, -6639, 533)
        },

        [2] = {
            [1] = Vector(3177, 3277, 312),
            [2] = Vector(4636, 1219, 423)
        }
    }
}

ZWA_CycleTimer = ZWA_CycleTimer or -1
ZWA_LightEnv = ZWA_LightEnv or nil
ZWA_LastSkyName = ZWA_LastSkyName or "sky_day01_01"

local lights_day = 12
local lights_night = 3

function SetUpMap()
    SetGlobalBool("zwa_cycle_isnight", false)
    ZWA_LightEnv = ents.FindByClass("light_environment")[1]
    
    if ZWA_LightEnv == nil then
        MsgC(Color(255, 255, 0), "WARNING: ", Color(255, 255, 255), "This map does not contain light environments\n")
    end

    RunConsoleCommand("sv_skyname", ZWA_LastSkyName)

    ZWA_CycleTimer = CurTime() + GetConVar("zwa_cycle_length_day"):GetInt()

    SetUpNPCSpawns()
end

function CycleThink()
    if GetConVar("zwa_cycle_toggle"):GetInt() == 0 then return end
    if ZWA_CycleTimer > CurTime() then return end
    
    CycleSwap()
end

function SetLightTime(isNight)
    local alphabet = "abcdefghijklmnopqrstuvwxyz"
    
    if isNight then
        
        ZWA_LastSkyName = "sky_day01_09"
        local pattLight = string.sub( alphabet, lights_night, lights_night )
        
        if ZWA_LightEnv ~= nil then
            ZWA_LightEnv:Fire( "SetPattern", pattLight, 0, nil, nil )
        end

        local pattAmb = string.sub( alphabet, lights_night, lights_night )

        engine.LightStyle( 0, pattAmb )

        timer.Simple(1, function() 
            net.Start("ZWA_LightEnv_Change")
            net.Broadcast()
        end)
    else
        ZWA_LastSkyName = "sky_day01_01"
        local pattLight = string.sub( alphabet, lights_day, lights_day )
        
        if ZWA_LightEnv ~= nil then
            ZWA_LightEnv:Fire( "SetPattern", pattLight, 0, nil, nil )
        end
        
        local pattAmb = string.sub( alphabet, lights_day, lights_day )

        engine.LightStyle( 0, pattAmb )

        timer.Simple(1, function() 
            net.Start("ZWA_LightEnv_Change")
            net.Broadcast()
        end)
    end

    RunConsoleCommand("sv_skyname", ZWA_LastSkyName)
end

function CycleSwap()
    if GetGlobalBool("zwa_cycle_isnight") == true then
        ZWA_CycleTimer = CurTime() + GetConVar("zwa_cycle_length_day"):GetInt()
        SetGlobalBool("zwa_cycle_isnight", false)

        for _, v in ipairs(player.GetAll()) do
            v:BroadcastSound("music/ravenholm_1.mp3")
        end
    elseif GetGlobalBool("zwa_cycle_isnight") == false then
        ZWA_CycleTimer = CurTime() + GetConVar("zwa_cycle_length_night"):GetInt()
        SetGlobalBool("zwa_cycle_isnight", true)
        
        for _, v in ipairs(player.GetAll()) do
            v:BroadcastSound("zwa/nightfall.wav")
        end
    end

    SetLightTime(GetGlobalBool("zwa_cycle_isnight"))
end

hook.Add("Tick", "ZWA_Cycle_Think", CycleThink)

hook.Add("PostCleanupMap", "ZWA_Map_PostClean", SetUpMap)
hook.Add("InitPostEntity", "ZWA_Map_PostEntity", SetUpMap)

concommand.Add("zwa_cycle_swap", function(ply)
    if !ply:IsAdmin() then return end

    CycleSwap()
end)