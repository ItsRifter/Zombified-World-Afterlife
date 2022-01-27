AddCSLuaFile()

GM.DB = {}
GM.DB.Items = {}
GM.DB.Weapons = {}
GM.DB.Skills = {}
GM.DB.Quests = {}
GM.DB.Shops = {}
GM.DB.CraftRecipes = {}
GM.DB.Buildings = {}

function CreateItem(newItem)
	GM.DB.Items[newItem.Name] = newItem
end

function CreateWeapon(newWeapon)
	GM.DB.Weapons[newWeapon.Name] = newWeapon
end

function CreateSkill(newSkill)
	GM.DB.Skills[newSkill.Name] = newSkill
end

function CreateTrader(shopTrader)
    GM.DB.Shops[shopTrader.Name] = shopTrader
end

function CreateQuest(newQuest)
    GM.DB.Quests[newQuest.Name] = newQuest
end

function CreateRecipe(newRecipe)
    GM.DB.CraftRecipes[newRecipe.Name] = newRecipe
end

function CreateBuilding(newBuilding)
    GM.DB.Buildings[newBuilding.Name] = newBuilding
end

GM.DefaultModels = {}