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