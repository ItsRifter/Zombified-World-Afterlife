AddCSLuaFile()

local ammo = {}
ammo.Name = "zwr_ammo_9mm"
ammo.DisplayName = "9MM Box"
ammo.Desc = "Standard 9MM box"
ammo.Model = "models/Items/BoxSRounds.mdl"
ammo.Cost = 250
ammo.SellingPrice = 85
ammo.SizeX = 1
ammo.SizeY = 1
ammo.StackAmount = 20
ammo.MaxStacks = 5
function ammo.OnUse(ply)
    ply:GiveAmmo(ammo.StackAmount, ammo.Name, true)
    InventoryRemoveItem(ply, ammo.Name)
end
CreateItem(ammo)

local ammo = {}
ammo.Name = "zwr_ammo_762_39mm"
ammo.DisplayName = "7.62x39mm Box"
ammo.Desc = "Assault Rifle ammo"
ammo.Model = "models/Items/BoxMRounds.mdl"
ammo.Cost = 1500
ammo.SellingPrice = 625
ammo.SizeX = 2
ammo.SizeY = 1
ammo.StackAmount = 30
ammo.MaxStacks = 3
function ammo.OnUse(ply)
    ply:GiveAmmo(ammo.StackAmount, ammo.Name, true)
    InventoryRemoveItem(ply, ammo.Name)
end
CreateItem(ammo)

local ammo = {}
ammo.Name = "zwr_ammo_388_mag"
ammo.DisplayName = "338 Lapua Magnum Box"
ammo.Desc = "Sniper rifle ammo"
ammo.Model = "models/Items/BoxSRounds.mdl"
ammo.Cost = 2500
ammo.SellingPrice = 1235
ammo.SizeX = 2
ammo.SizeY = 2
ammo.StackAmount = 10
ammo.MaxStacks = 4
function ammo.OnUse(ply)
    ply:GiveAmmo(ammo.StackAmount, ammo.Name, true)
    InventoryRemoveItem(ply, ammo.Name)
end

CreateItem(ammo)

local woodMat = {}
woodMat.Name = "zwr_mat_wood"
woodMat.DisplayName = "Box of Wood"
woodMat.Desc = "A box containing wood"
woodMat.Model = "models/Items/item_item_crate.mdl"
woodMat.Class = "ent_jack_gmod_ezwood"
woodMat.Cost = 650
woodMat.SellingPrice = 250
woodMat.SizeX = 1
woodMat.SizeY = 1
woodMat.StackAmount = 25
woodMat.MaxStacks = 4

CreateItem(woodMat)

local crowbar = {}
crowbar.Name = "zwr_weapon_crowbar"
crowbar.DisplayName = "Crowbar"
crowbar.Desc = "A metal crowbar, used for melee defence"
crowbar.Class = "weapon_crowbar"
crowbar.Model = "models/weapons/w_crowbar.mdl"
crowbar.AmmoType = nil
crowbar.Cost = 500
crowbar.SellingPrice = 250
crowbar.SizeX = 3
crowbar.SizeY = 1
function crowbar.OnUse(ply)
    ply:Give(crowbar.Class)
end

CreateWeapon(crowbar)

local glock = {}
glock.Name = "zwr_weapon_glock"
glock.DisplayName = "Glock P80"
glock.Desc = "A Glock P80\nAMMO TYPE: 9MM bullets"
glock.Class = "tfa_ins2_glock_p80"
glock.Model = "models/weapons/tfa_ins2/w_glock_p80.mdl"
glock.AmmoType = "zwr_ammo_9mm"
glock.Cost = 1500
glock.SellingPrice = 850
glock.SizeX = 2
glock.SizeY = 2
function glock.OnUse(ply)
    ply:Give(glock.Class)
end
CreateWeapon(glock)

local wornAK = {}
wornAK.Name = "zwr_weapon_ak47"
wornAK.DisplayName = "Battle-Torn Ak-47"
wornAK.Desc = "This AK-47 has seen better days\nAMMO TYPE: 7.62x39mm Ammo"
wornAK.Class = "tfa_ins2_akm_bw"
wornAK.Model = "models/weapons/tfa_ins2/w_akm_bw.mdl"
wornAK.AmmoType = "zwr_ammo_762_39mm"
wornAK.Cost = 6500
wornAK.SellingPrice = 2750
wornAK.SizeX = 5
wornAK.SizeY = 2
function wornAK.OnUse(ply)
    ply:Give(wornAK.Class)
end

CreateWeapon(wornAK)

local awm = {}
awm.Name = "zwr_weapon_awm"
awm.DisplayName = "AWM"
awm.Desc = "A big sniper rifle use for long range\nAMMO TYPE: .388 Magnum Ammo"
awm.Class = "tfa_ins2_warface_awm"
awm.Model = "models/weapons/w_ins2_warface_awm.mdl"
awm.AmmoType = "zwr_ammo_388_mag"
awm.Cost = 12500
awm.SellingPrice = 4525
awm.SizeX = 6
awm.SizeY = 2
function awm.OnUse(ply)
    ply:Give(awm.Class)
end

CreateWeapon(awm)

function GM:Initialize()
    
    game.AddAmmoType( {
        name = "zwr_ammo_9mm",
        dmgtype = DMG_BULLET,
        tracer = TRACER_LINE,
        plydmg = 25,
        npcdmg = 30,
        force = 500,
        minsplash = 10,
        maxsplash = 5
    } )
    
    game.AddAmmoType( {
        name = "zwr_ammo_762_39mm",
        dmgtype = DMG_BULLET,
        tracer = TRACER_LINE,
        plydmg = 30,
        npcdmg = 45,
        force = 1000,
        minsplash = 10,
        maxsplash = 5
    } )
    
    game.AddAmmoType( {
        name = "zwr_ammo_388_mag",
        dmgtype = DMG_BULLET,
        tracer = TRACER_LINE,
        plydmg = 75,
        npcdmg = 85,
        force = 2000,
        minsplash = 10,
        maxsplash = 5
    } )
end