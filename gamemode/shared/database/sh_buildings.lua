AddCSLuaFile()

local base = {}
base.Name = "Faction Base"
base.Desc = "The heart of your faction"
base.Model = "models/props_trainstation/trainstation_ornament001.mdl"
base.Class = "ent_zwr_faction_base"
base.Cost = 5000
base.SellingPrice = 3000
base.MaxLimit = 1
CreateBuilding(base)

local fridge = {}
fridge.Name = "Fridge"
fridge.Desc = "Stores and keeps food fresh"
fridge.Model = "models/props_c17/FurnitureFridge001a.mdl"
fridge.Class = "ent_zwr_faction_fridge"
fridge.Cost = 3000
fridge.SellingPrice = 1000
fridge.MaxLimit = 3
CreateBuilding(fridge)

local stove = {}
stove.Name = "Cooking Stove"
stove.Desc = "Cook the food\nlike that angry chef"
stove.Model = "models/props_c17/furnitureStove001a.mdl"
stove.Class = "ent_zwr_faction_stove"
stove.Cost = 4000
stove.SellingPrice = 1500
stove.MaxLimit = 2
CreateBuilding(stove)

local fridge2 = {}
fridge2.Name = "Fridge MK2"
fridge2.Desc = "Store even more food\nwhile keeping it fresh"
fridge2.Model = "models/props_wasteland/kitchen_fridge001a.mdl"
fridge2.Class = "ent_zwr_faction_fridge_mk2"
fridge2.Cost = 6500
fridge2.SellingPrice = 2500
fridge2.MaxLimit = 2
CreateBuilding(fridge2)

local mattress = {}
mattress.Name = "Bed Mattress"
mattress.Desc = "A place to sleep\nServes as a spawnpoint"
mattress.Model = "models/props_c17/FurnitureMattress001a.mdl"
mattress.Class = "ent_zwr_faction_bed"
mattress.Cost = 500
mattress.SellingPrice = 250
mattress.MaxLimit = 5
CreateBuilding(mattress)
