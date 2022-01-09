AddCSLuaFile()

local ammo = {}
ammo.Name = "zwr_ammo_9mm"
ammo.DisplayName = "9MM Box"
ammo.Model = "models/props_lab/box01a.mdl"
ammo.Cost = 500
ammo.SellingPrice = 165
ammo.SizeX = 1
ammo.SizeY = 1
ammo.StackAmount = 12
ammo.MaxStacks = 5

CreateItem(ammo)

local ammo = {}
ammo.Name = "zwr_ammo_762_39mm"
ammo.DisplayName = "7.62x39mm Box"
ammo.Model = "models/props_lab/box01a.mdl"
ammo.Cost = 1500
ammo.SellingPrice = 625
ammo.SizeX = 2
ammo.SizeY = 1
ammo.StackAmount = 30
ammo.MaxStacks = 3

CreateItem(ammo)

local ammo = {}
ammo.Name = "zwr_ammo_388_mag"
ammo.DisplayName = "338 Lapua Magnum Box"
ammo.Model = "models/props_lab/box01a.mdl"
ammo.Cost = 2500
ammo.SellingPrice = 1235
ammo.SizeX = 2
ammo.SizeY = 2
ammo.StackAmount = 10
ammo.MaxStacks = 4

CreateItem(ammo)

local glock = {}
glock.Name = "zwr_weapon_glock"
glock.DisplayName = "Glock P80"
glock.Class = "tfa_ins2_glock_p80"
glock.Model = "models/weapons/tfa_ins2/w_glock_p80.mdl"
glock.AmmoType = "zwr_ammo_9mm"
glock.Cost = 1500
glock.SellingPrice = 850
glock.SizeX = 2
glock.SizeY = 2

CreateWeapon(glock)

local wornAK = {}
wornAK.Name = "zwr_weapon_ak47"
wornAK.DisplayName = "Battle-Torn Ak-47"
wornAK.Class = "tfa_ins2_akm_bw"
wornAK.Model = "models/weapons/tfa_ins2/w_akm_bw.mdl"
wornAK.AmmoType = "zwr_ammo_762_39mm"
wornAK.Cost = 6500
wornAK.SellingPrice = 2750
wornAK.SizeX = 5
wornAK.SizeY = 2

CreateWeapon(wornAK)

local awm = {}
awm.Name = "zwr_weapon_awm"
awm.DisplayName = "AWM"
awm.Class = "tfa_ins2_warface_awm"
awm.Model = "models/weapons/w_ins2_warface_awm.mdl"
awm.AmmoType = "zwr_ammo_388_mag"
awm.Cost = 12500
awm.SellingPrice = 4525
awm.SizeX = 6
awm.SizeY = 2

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