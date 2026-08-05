-- ============================================================================
-- weapon_zs_f_watermelon - 西瓜食物武器
-- 负责：继承食物武器基础，提供可食用的西瓜块，食用后恢复生命值
-- ============================================================================
AddCSLuaFile()

-- 继承食物武器基础（基类负责食用逻辑）
SWEP.Base = "weapon_zs_basefood"

-- 武器显示名称（本地化键）
SWEP.PrintName = ""..translate.Get("weapon_zs_f_watermelon")

if CLIENT then
	-- 客户端：第一人称视野大小
	SWEP.ViewModelFOV = 80

	-- 客户端：第一人称视角下的模型元素（西瓜块挂在右手骨上）
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_junk/watermelon01_chunk02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(1, 4, -3), angle = Angle(-45, -70, -80), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 客户端：世界模型下的模型元素（第三人称显示）
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_junk/watermelon01_chunk02a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 1, -3), angle = Angle(0, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 第一人称视角模型（借用警棍模型作为持握载体）
SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
-- 世界模型（掉在地上的西瓜块）
SWEP.WorldModel = "models/props_junk/watermelon01_chunk02a.mdl"

-- 主攻击消耗的弹药类型（食物类弹药）
SWEP.Primary.Ammo = "foodwatermelon"

-- 食用后恢复的生命值
SWEP.FoodHealth = 15
-- 食用所需时间（秒）
SWEP.FoodEatTime = 4
