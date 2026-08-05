-- ============================================================================
-- weapon_zs_f_takeout.lua - 外卖盒（食物道具）
-- 负责：定义外卖盒的模型外观（手持显示）与食用属性（回复量/食用耗时）
-- ============================================================================

-- 注册为共享文件（客户端也需加载）
AddCSLuaFile()

-- 母本：食物基础
SWEP.Base = "weapon_zs_basefood"

-- 道具显示名称
SWEP.PrintName = ""..translate.Get("weapon_zs_f_takeout")

if CLIENT then
	-- 第一人称附加模型：手持外卖盒
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_junk/garbage_takeoutcarton001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.75, 2.5, -2), angle = Angle(180, 0, 0), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 世界模型附加模型：第三人称手持外卖盒
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_junk/garbage_takeoutcarton001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.75, 2.5, -2), angle = Angle(180, 0, -25), size = Vector(0.5, 0.5, 0.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 第一人称模型（手雷模型占位，实际隐藏）
SWEP.ViewModel = "models/weapons/c_grenade.mdl"
-- 世界模型：外卖盒
SWEP.WorldModel = "models/props_junk/garbage_takeoutcarton001a.mdl"

-- 消耗的食物弹药类型：外卖
SWEP.Primary.Ammo = "foodtakeout"

-- 食用回复的生命值
SWEP.FoodHealth = 17
-- 食用所需时间（秒）
SWEP.FoodEatTime = 5
