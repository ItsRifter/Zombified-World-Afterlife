local ZWA_Player = FindMetaTable( "Player" )

function ZWA_Player:SetUpInventory()
	if SERVER then
		if not self then return false end

		if not self.PLAYERINV_META then
			self.PLAYERINV_META = { Player = self }

			setmetatable( self.PLAYERINV_META, PLAYERINV_META )
		end

		return self.PLAYERINV_META
	else
		return ZWA_INV.LOCAL_PLAYERINV_META
	end
end

function ZWA_Player:GetInventory()
    return self.InvTable or {}
end

function ZWA_Player:GetUserID()
	return self.UserID or 0
end