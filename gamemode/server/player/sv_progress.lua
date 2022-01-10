
function AddXP(ply, amt)
    ply.ZWR.EXP = ply.ZWR.EXP + amt

    local notifyLevel = false

    --In case an admin gives too much exp to the player (or self)
    --While the players exp is over the required amount, increase their statistics
    while ply.ZWR.EXP >= ply.ZWR.ReqEXP do
        ply.ZWR.EXP = ply.ZWR.EXP - ply.ZWR.ReqExp
		ply.ZWR.Level = ply.ZWR.Level + 1
		ply.ZWR.SkillPoints = ply.ZWR.SkillPoints + 1
		ply.ZWR.ReqExp = ply.ZWR.ReqExp + (750 * ply.ZWR.Level)
        
        notifyLevel = true 
    end

    if notifyLevel then
		ply:SetNWInt("ZWR_SkillPoints", ply.ZWR.SkillPoints)
		ply:SetNWInt("ZWR_Level", ply.ZWR.Level)
		ply:SetNWInt("ZWR_ReqXP", ply.ZWR.ReqExp)
    end

    ply:SetNWInt("ZWR_XP", ply.ZWR.EXP)
end

function AddCash(ply, amt)
    ply.ZWR.Money = ply.ZWR.Money + amt
    ply:SetNWInt("ZWR_Cash", ply.ZWR.Money)
end

function AddBounty(ply, amt)
    ply.curBounty = ply.curBounty + amt
    ply:SetNWInt("ZWR_Bounty", ply.curBounty)
end

concommand.Add("zwr_addxp", function(ply, cmd, args)
    if not ply:IsAdmin() then return end
	
	local target = nil

    if args[2] then
        for _, v in ipairs(player.GetAll()) do
            if target and string.find(target:Nick(), string.lower(string.sub(v:Nick(), 0, #args[2]))) then
                ply:PrintMessage(HUD_PRINTCONSOLE, "There are multiple users with this name, be more specific if possible")
                return
            end
            
            if string.find(string.lower(v:Nick()), string.lower(args[2])) then
                target = v
            end
        end
	end

	if target then
		AddXP(target, args[1])
		target:ChatPrint("You were given " .. args[1] .. "XP by an admin")
		ply:PrintMessage(HUD_PRINTCONSOLE, args[1] .. "XP given to " .. target:Nick())
        MsgN(ply:Nick() .. " gave " .. args[1] .. " XP to " .. target:Nick())
    else
        ply:PrintMessage(HUD_PRINTCONSOLE, "You gave yourself " .. args[1] .. " XP")
        AddXP(ply, args[1])
        MsgN(ply:Nick() .. " gave " .. args[1] .. " XP to self")
    end
end)

concommand.Add("zwr_addcash", function(ply, cmd, args)
    if not ply:IsAdmin() then return end
	
	local target = nil

    if args[2] then
        for _, v in ipairs(player.GetAll()) do
            if target and string.find(target:Nick(), string.lower(string.sub(v:Nick(), 0, #args[2]))) then
                ply:ChatPrint("There are multiple users with this name, be more specific if possible")
                return
            end
            
            if string.find(string.lower(v:Nick()), string.lower(args[2])) then
                target = v
            end
        end
	end

	if target then
		AddCash(target, args[1])
		target:ChatPrint("You were given " .. args[1] .. " Cash by an admin")
		ply:PrintMessage(HUD_PRINTCONSOLE, args[1] .. " Cash given to " .. target:Nick())
        MsgN(ply:Nick() .. " gave " .. args[1] .. " cash to " .. target:Nick())
    else
        ply:PrintMessage(HUD_PRINTCONSOLE, "You gave yourself " .. args[1] .. " Cash")
        AddCash(ply, args[1])
        MsgN(ply:Nick() .. " gave " .. args[1] .. " cash to self")
    end
end)

concommand.Add("zwr_addbounty", function(ply, cmd, args)
    if not ply:IsAdmin() then return end
	
	local target = nil

    if args[2] then
        for _, v in ipairs(player.GetAll()) do
            if target and string.find(target:Nick(), string.lower(string.sub(v:Nick(), 0, #args[2]))) then
                ply:PrintMessage(HUD_PRINTCONSOLE, "There are multiple users with this name, be more specific if possible")
                return
            end
            
            if string.find(string.lower(v:Nick()), string.lower(args[2])) then
                target = v
            end
        end
	end

	if target then
		AddBounty(target, args[1])
		target:ChatPrint("You were given " .. args[1] .. " Bounty by an admin")
		ply:PrintMessage(HUD_PRINTCONSOLE, args[1] .. " Bounty given to " .. target:Nick())
        MsgN(ply:Nick() .. " gave " .. args[1] .. " bounty to " .. target:Nick())
    else
        ply:PrintMessage(HUD_PRINTCONSOLE, "You gave yourself " .. args[1] .. " Bounty")
        AddBounty(ply, args[1])
        MsgN(ply:Nick() .. " gave " .. args[1] .. " bounty to self")
    end
end)