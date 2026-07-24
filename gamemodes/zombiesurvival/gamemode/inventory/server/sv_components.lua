-- ========== 世界物品转化配方表 ==========

-- 世界场景中的物理模型可以转化为组件的配方表
GM.WorldConversions = {}

-- ========== 初始饰品列表 ==========

-- 新玩家初次进入游戏时自动获得的初始饰品
GM.StarterTrinkets = {
	"trinket_armband",
	"trinket_condiments",
	"trinket_emanual",
	"trinket_aimaid",
	"trinket_vitamins",
	"trinket_welfare",
	"trinket_chemistry"
}

-- ========== 注册世界物品转化配方 ==========

-- 将指定的场景模型注册为可转化为特定组件
function GM:AddWorldPropConversionRecipe(model, result)
	local datatab = {Result = result, Index = wcindex}
	self.WorldConversions[model] = datatab
	self.WorldConversions[#self.WorldConversions + 1] = datatab
end

-- ========== 世界物品转化配方列表 ==========

GM:AddWorldPropConversionRecipe("models/props_combine/breenbust.mdl", 		"comp_busthead")
GM:AddWorldPropConversionRecipe("models/props_junk/sawblade001a.mdl", 		"comp_sawblade")
GM:AddWorldPropConversionRecipe("models/props_junk/propane_tank001a.mdl", 	"comp_propanecan")
GM:AddWorldPropConversionRecipe("models/items/car_battery01.mdl", 			"comp_electrobattery")
GM:AddWorldPropConversionRecipe("models/props_lab/reciever01b.mdl", 		"comp_reciever")
GM:AddWorldPropConversionRecipe("models/props_lab/harddrive01.mdl", 		"comp_cpuparts")
