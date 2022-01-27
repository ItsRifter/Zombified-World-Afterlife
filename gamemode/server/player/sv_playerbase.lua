--Stamina
local staminaRate = 0.10
local staminaRegen = 0.20
local staminaDelay = 4

--Respawn
local respawnDelay = 10

--Flashlight
local flashRate = 0.025
local flashRegen = 0.05
local flashDelay = 5

--Picking up stuff
local nextPickup = 0
local pickUpCooldown = 1

SOUNDS_MALE_HURT = {
	[1] = "vo/npc/male01/pain01.wav",
	[2] = "vo/npc/male01/pain02.wav",
	[3] = "vo/npc/male01/pain03.wav",
	[4] = "vo/npc/male01/pain04.wav",
	[5] = "vo/npc/male01/pain05.wav",
    [6] = "vo/npc/male01/pain06.wav",
    [7] = "vo/npc/male01/pain07.wav",
    [8] = "vo/npc/male01/pain08.wav",
    [9] = "vo/npc/male01/pain09.wav",
}

SOUNDS_FEMALE_HURT = {
	[1] = "vo/npc/female01/pain01.wav",
	[2] = "vo/npc/female01/pain02.wav",
	[3] = "vo/npc/female01/pain03.wav",
	[4] = "vo/npc/female01/pain04.wav",
	[5] = "vo/npc/female01/pain05.wav",
    [6] = "vo/npc/female01/pain06.wav",
    [7] = "vo/npc/female01/pain07.wav",
    [8] = "vo/npc/female01/pain08.wav",
    [9] = "vo/npc/female01/pain09.wav",
}

function NewPlayerInventory(ply)
    if ply.ZWR.Inventory then
        InventoryGiveItem(ply, "zwr_weapon_crowbar")
        InventoryGiveItem(ply, "zwr_weapon_glock")
        for i = 1, 4 do 
            InventoryGiveItem(ply, "zwr_ammo_9mm")
        end

        AddCash(ply, 2500)
    end
end

function InitInventory(ply)

    ply:SetNWInt("ZWR_Inventory_SlotWidth", ply.ZWR.InvMaxSlotsWidth)
    ply:SetNWInt("ZWR_Inventory_SlotHeight", ply.ZWR.InvMaxSlotsHeight)

    net.Start("ZWR_Inventory_Init")
    net.Send(ply)
        
    for i, v in pairs(ply.ZWR.Inventory) do
        net.Start("ZWR_Inventory_UpdateItem")
            net.WriteString(v.Name)
        net.Send(ply)
    end
end

function InventoryGetItem(ply, className)
    for k, v in pairs(GAMEMODE.DB.Items) do
        if v.Class == className or v.Name == className then
            return v
        end
    end

    for k, w in pairs(GAMEMODE.DB.Weapons) do
        if w.Class == className or w.Name == className then
            return w
        end
    end

    return nil
end

function InventoryGiveItem(ply, className)
    local item = InventoryGetItem(ply, className)

    if item ~= nil then
        table.insert(ply.ZWR.Inventory, item)

        net.Start("ZWR_Inventory_UpdateItem")
            net.WriteString(item.Name)
        net.Send(ply)
    end
end

function InventoryRemoveItem(ply, className)
    local updateClientItem
   
    for k, v in pairs(GAMEMODE.DB.Items) do
        if v.Name == className then
            updateClientItem = v.Name
            table.RemoveByValue(ply.ZWR.Inventory, v)
        end
    end

    for k, w in pairs(GAMEMODE.DB.Weapons) do
        if w.Name == className then
            updateClientItem = w.Name
            table.RemoveByValue(ply.ZWR.Inventory, w)
        end
    end

    net.Start("ZWR_Inventory_Refresh_Remove")
        net.WriteString(updateClientItem)
    net.Send(ply)
end

--Inventory check, if the player has the item then return true else false
function InventoryHasItem(ply, className) 
    
    --Checks for each item in inventory, both name and class
    for k, v in pairs(GAMEMODE.DB.Items) do
        if v.Name == className then
            return true
        end
    end

    --Same as above but for weapons
    for k, w in pairs(GAMEMODE.DB.Weapons) do
        if w.Name == className or w.Class == className then
            return true
        end
    end

    return false
end

function PlayerSpawn(ply)
    ply.spawnProtection = 10 + CurTime()
    
    ply.lastSprint = 0
    ply.lastFlash = 0
    ply.respawnTime = 0

    ply.playerStamina = 100
    ply.flashBattery = 100
    ply.curBounty = ply.curBounty or 0

    ply.faction = ply.faction or {
        ["name"] = "Loner",
        ["owner"] = nil,
        ["inviteOnly"] = false,
        ["colour"] = Color(165, 165, 165),
        ["curPlayers"] = nil
    }

    --Give default weapons
    ply:Give("wep_jack_gmod_hands")
    ply:Give("weapon_physcannon")

    --Network statuses
    ply:SetNWInt("ZWR_Stat_Stamina", ply.playerStamina)
    ply:SetNWInt("ZWR_Stat_FlashlightBattery", ply.flashBattery)

    --Network Time
    ply:SetNWInt("ZWR_Time", server_cycleTime)
    ply:SetNWBool("ZWR_Time_IsInvasion", server_isNightTime)

    --Network the statistics if its a player
    if not ply:IsBot() then
        ply:SetModel(ply.ZWR.Model)

        ply:SetNWInt("ZWR_Level", ply.ZWR.Level)
        ply:SetNWInt("ZWR_XP", ply.ZWR.EXP)
        ply:SetNWInt("ZWR_ReqXP", ply.ZWR.ReqEXP)
        ply:SetNWInt("ZWR_SkillPoints", ply.ZWR.SkillPoints)

        ply:SetNWInt("ZWR_Cash", ply.ZWR.Money)
        ply:SetNWInt("ZWR_Bounty", ply.curBounty)

        ply:SetNWString("ZWR_Faction", ply.faction.name)
        if GetConVar("zwr_cycle_enabled"):GetInt() == 1 then
            ply:SetNWBool("ZWR_Time_Enable", true)
        else
            ply:SetNWBool("ZWR_Time_Enable", false)
        end

    end
end

concommand.Add("zwr_reloadinv", function(ply)
    if not ply:IsAdmin() then return end

    InitInventory(ply)
end)

concommand.Add("zwr_clearinv", function(ply, cmd, args)
    if not ply:IsSuperAdmin() then return end
	
	local target = nil

    if args[1] then
        for _, v in ipairs(player.GetAll()) do
            if target and string.find(target:Nick(), string.lower(string.sub(v:Nick(), 0, #args[1]))) then
                ply:PrintMessage(HUD_PRINTCONSOLE, "There are multiple users with this name, be more specific if possible")
                return
            end
            
            if string.find(string.lower(v:Nick()), string.lower(args[1])) then
                target = v
            end
        end
	end

	if target then
        for i, item in pairs(target.ZWR.Inventory) do
            InventoryRemoveItem(target, item.Name)
        end

        table.Empty(target.ZWR.Inventory)

        target:StripWeapons()
		target:ChatPrint("Your inventory was cleared by an admin")
		ply:PrintMessage(HUD_PRINTCONSOLE, target:Nick() .. "'s inventory cleared")
        MsgN(ply:Nick() .. " cleared " .. target:Nick() .. "'s inventory")
    else
        for i, item in pairs(ply.ZWR.Inventory) do
            InventoryRemoveItem(ply, item.Name)
        end

        table.Empty(ply.ZWR.Inventory)
        ply:StripWeapons()
        ply:PrintMessage(HUD_PRINTCONSOLE, "You cleared your inventory")
        MsgN(ply:Nick() .. " cleared inventory")
    end
end)

concommand.Add("zwr_giveitem", function(ply, cmd, args)
    if not ply:IsAdmin() then return end
    
    local item = InventoryGetItem(ply, args[1])
    if item == nil then 
        ply:PrintMessage(HUD_PRINTCONSOLE, "Invalid item")
        return 
    end

    InventoryGiveItem(ply, item.Name)
end)

hook.Add("PlayerInitialSpawn", "ZWR_PlayerInitialSpawn", function(ply, transition)
    PlayerSpawn(ply)
    timer.Create("ZWR_InitInventory_" .. ply:UserID(), 4, 1, function()
        InitInventory(ply)

        for i, f in pairs(CURRENT_FACTIONS) do
            net.Start("ZWR_Faction_Create_Server")
                net.WriteString(f.name)
                net.WriteEntity(f.owner)
                net.WriteBool(f.inviteOnly)
                net.WriteTable(f.curPlayers)
            net.Send(ply)
        end
    end)
end)

hook.Add("PlayerSpawn", "ZWR_PlayerRespawn", function(ply, transition)
    PlayerSpawn(ply)
end)

function GM:PlayerShouldTakeDamage( ply, attacker )
    if attacker:IsPlayer() then
        if ply:GetNWString("ZWR_Faction", "Loner") == attacker:GetNWString("ZWR_Faction", "Loner") then
            return false
        end
    end

    return true
end

function GM:PlayerHurt(victim, attacker, healthRemaining, damageTaken)
    
    --If the player has spawn protection, restore health to max
    if victim.spawnProtection > CurTime() then 
        victim:SetHealth(victim:GetMaxHealth())
        return
    end
    
    --If the player is too low of a level, don't allow them to be damaged
    if victim.ZWR.Level < 5 and victim:GetNWString("ZWR_Faction") ~= "Loner" and attacker:IsPlayer() then 
        attacker:ChatPrint("That player is under 'Newbie Protection'")
        victim:SetHealth(victim:GetMaxHealth())
        return
    end

    --Play hurt sounds
    if string.find(victim:GetModel(), "male") then
        victim:EmitSound(SOUNDS_MALE_HURT[math.random(1, #SOUNDS_MALE_HURT)])
    elseif string.find(victim:GetModel(), "female") then
        victim:EmitSound(SOUNDS_FEMALE_HURT[math.random(1, #SOUNDS_FEMALE_HURT)])
    end
end

function GM:PlayerDeathThink( ply )
    --After a set time has passed, respawn the player
    if ply.respawnTime < CurTime() then
        ply:Spawn()
    end

    --Don't allow default respawning by the player (Mouse 1: Respawn)
    return false
end

--Disable standard picking up items
function GM:PlayerCanPickupItem( ply, item )
    return false
end

--Surpasses the check in PlayerCanPickupWeapon so players can pick up without checking inventory
local SURPASS_CHECK = {
    ["weapon_physcannon"] = true,
    ["wep_jack_gmod_ezmedkit"] = true,
    ["wep_jack_gmod_hands"] = true,
    ["weapon_zwr_builder"] = true,
    ["weapon_zwr_deconstructor"] = true
}

function GM:PlayerCanPickupWeapon( ply, weapon )

    if SURPASS_CHECK[weapon:GetClass()] then 
        return true
    end
    
    if InventoryHasItem(ply, weapon:GetClass()) then
        return true
    end
    
    return false
end



function GM:PlayerUse( ply, ent )

    if not ent.ClassName or not InventoryGetItem(ply, ent.ClassName) then return end

    if ply.nextPickup and ply.nextPickup > CurTime() then return end

    InventoryGiveItem(ply, ent.ClassName)
    ply.nextPickup = pickUpCooldown + CurTime()
    ent:Remove()
end


function BroadcastSound(soundFile, targetPlayer)
    net.Start("ZWR_BroadcastSound")
    net.WriteString(soundFile)

    if targetPlayer then
        net.Send(targetPlayer)
    else
        net.Broadcast()
    end
end

function GM:PlayerDeath(victim, inflictor, attacker)
    --On death, set their respawn time and divide bounty
    victim.respawnTime = respawnDelay + CurTime()
    victim.curBounty = victim.curBounty / 2

    --Dying sound
    if string.find(victim:GetModel(), "male") then
        victim:EmitSound(SOUNDS_MALE_HURT[math.random(1, #SOUNDS_MALE_HURT)])
    elseif string.find(victim:GetModel(), "female") then
        victim:EmitSound(SOUNDS_FEMALE_HURT[math.random(1, #SOUNDS_FEMALE_HURT)])
    end
end

hook.Add("PlayerPostThink", "ZWR_PlayerPostThink", function(ply)
    --Regens stamina
    if ply.lastSprint < CurTime() and ply.playerStamina < 100 then
        ply.playerStamina = math.Clamp(ply.playerStamina + staminaRegen, 1, 100)
        ply:SetNWInt("ZWR_Stat_Stamina", math.Round(ply.playerStamina))
    end

    --If we're moving, not crouching and sprinting with stamina above 0, start sprinting
    if ply:KeyDown( IN_FORWARD ) and not ply:KeyDown(IN_DUCK) and ply:KeyDown( IN_SPEED ) and ply.playerStamina > 0 then
        ply.lastSprint = staminaDelay + CurTime()
        ply.playerStamina = ply.playerStamina - staminaRate
        ply:SetNWInt("ZWR_Stat_Stamina", math.Round(ply.playerStamina))
    end

    if ply.flashBattery <= 0 then
        ply:Flashlight(false)
        ply:AllowFlashlight( false )
    else
        ply:AllowFlashlight( true )
    end

    if ply:FlashlightIsOn() and ply.flashBattery > 0 then
        ply.lastFlash = flashDelay + CurTime()
        ply.flashBattery = ply.flashBattery - flashRate
        ply:SetNWInt("ZWR_Stat_FlashlightBattery", ply.flashBattery)

    elseif not ply:FlashlightIsOn() and ply.flashBattery < 100 and ply.lastFlash <= CurTime() then
        
        ply.flashBattery = math.Clamp(ply.flashBattery + flashRegen, 0, 100)

        ply:SetNWInt("ZWR_Stat_FlashlightBattery", ply.flashBattery)

    end
end)

--Handles Movement
hook.Add("Move", "ZWR_Movement", function(ply, mv)

    mv:SetMaxClientSpeed( 150 )

    --If sprinting and stamina is sufficent, increase the speed 
    if ply:KeyDown( IN_SPEED ) and not ply:KeyDown( IN_DUCK ) and ply:KeyDown( IN_FORWARD ) and ply.playerStamina > 0 then       
        local speed = mv:GetMaxSpeed() * 1.65
        mv:SetMaxClientSpeed( speed )
    end

    --If Crouching, reduce speed
    if ply:KeyDown( IN_DUCK ) then
        local speed = mv:GetMaxSpeed() / 1.65
        mv:SetMaxClientSpeed( speed )
    end	
end)

net.Receive("ZWR_Inventory_UseItem", function(len, ply)
    if not ply then return end
    
    local itemType = net.ReadString()

    if InventoryHasItem(ply, itemType) then
        local item = InventoryGetItem(ply, itemType)

        if item.OnUse then
            item.OnUse(ply)
        end
    end
end)

net.Receive("ZWR_Inventory_DropItem", function(len, ply)
    if not ply then return end

    local itemType = net.ReadString()

    if not InventoryHasItem(ply, itemType) then return end
    local item = InventoryGetItem(ply, itemType)

    local tr = util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * 50,
        filter = ply,
    } )

    if string.find(item.Name, "weapon") then
        local droppedWeapon = ents.Create("ent_zwr_item")
        
        droppedWeapon.ClassName = item.Class
        droppedWeapon:SetModel(item.Model)
        droppedWeapon:SetPos(tr.HitPos)
        droppedWeapon:SetAngles(Angle(0, 0, 0))
        droppedWeapon:Spawn()

        if ply:HasWeapon(item.Class) then
            ply:StripWeapon(item.Class)
        end

    elseif string.find(item.Name, "ammo") then
        local droppedItem = ents.Create("ent_zwr_item")
        droppedItem.ClassName = item.Class
        droppedItem:SetModel(item.Model)
        droppedItem:SetPos(tr.HitPos)
        droppedItem:SetAngles(Angle(0, 0, 0))
        droppedItem:Spawn()
    elseif string.find(item.Name, "mat") then
        local droppedItem = ents.Create(item.Class)
        droppedItem:SetModel(item.Model)
        droppedItem:SetPos(tr.HitPos)
        droppedItem:SetAngles(Angle(0, 0, 0))
        droppedItem:Spawn()
    end

    InventoryRemoveItem(ply, itemType)
end)


net.Receive("ZWR_SellItem", function(len, ply)
    local itemType = net.ReadString()

    if InventoryHasItem(ply, itemType) then
        local sellingItem = InventoryGetItem(ply, itemType)
        
        ply.ZWR.Money = ply.ZWR.Money + sellingItem.SellingPrice
        ply:SetNWInt("ZWR_Cash", ply.ZWR.Money)
        
        if string.find(sellingItem.Name, "weapon") then
            if ply:HasWeapon(sellingItem.Class) then
                ply:StripWeapon(sellingItem.Class)
            end
        end

        InventoryRemoveItem(ply, itemType)
        timer.Simple(0.1, function()
            net.Start("ZWR_Shop_UpdateCash")
            net.Send(ply)
        end)
    end
end)

net.Receive("ZWR_BuyItem", function(len, ply)
    if not ply then return end
    
    local itemType = net.ReadString()

    local item = InventoryGetItem(ply, itemType)

    if not item then return end

    InventoryGiveItem(ply, itemType)

    ply.ZWR.Money = ply.ZWR.Money - item.Cost

    net.Start("ZWR_Inventory_Refresh_Add")
    net.Send(ply)

    ply:SetNWInt("ZWR_Cash", ply.ZWR.Money)
end)