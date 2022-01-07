AddCSLuaFile()

local Player = FindMetaTable("Player")

function Player:AddWeapon(itemName, amount)
	
    if !IsValid(self) then return false end

	local item = GAMEMODE.DB.Items[itemName]

	if !item then return false end

	amount = tonumber(amount) or 1
	
	if intAmount == 0 then return false end
	
    table.insert(self.ZWR.Inventory, item)

	return true
end

concommand.Add("zwr_giveitem", function(ply, cmd, args)
    if not ply:IsAdmin() then return end
    local item, amount, targetply, target = args[1], args[2], ply, args[3]
	if ply:EntIndex() == 0 and !target then	
		print("No Target specified. You cannot give items to console!")
		return
	end
	
	if not item then
		ply:PrintMessage(HUD_PRINTCONSOLE, "ERROR: No item specified.")
		return 	
	end

	if not amount then
		ply:PrintMessage(HUD_PRINTCONSOLE, "ERROR: No amount specified.")
		return
	end

	targetply:AddItem(item, amount)
end)