-- ============================================================================
-- weapon_zs_f_banana.lua - 香蕉（食物道具）
-- 负责：定义香蕉的模型外观（手持显示）与食用属性（回复量/食用耗时）
-- ============================================================================

-- 注册为共享文件（客户端也需加载）
AddCSLuaFile()

-- 母本：食物基础
SWEP.Base = "weapon_zs_basefood"

-- 道具显示名称
SWEP.PrintName = ""..translate.Get("weapon_zs_f_banana")

if CLIENT then
	-- 第一人称骨骼调整：右手食指弯曲（握住香蕉的握姿）
	SWEP.ViewModelBoneMods = {
		["ValveBiped.Bip01_R_Finger02"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 59, 0) },
	}

	-- 第一人称附加模型：手持香蕉
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props/cs_italy/bananna.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2, 2.5, -1), angle = Angle(0, 0, 120), size = Vector(0.75, 0.75, 0.75), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 世界模型附加模型：第三人称手持香蕉
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props/cs_italy/bananna.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 2.5, -1), angle = Angle(0, 0, 120), size = Vector(0.75, 0.75, 0.75), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 第一人称模型（手雷模型占位，实际隐藏）
SWEP.ViewModel = "models/weapons/c_grenade.mdl"
-- 世界模型：香蕉
SWEP.WorldModel = "models/props/cs_italy/bananna.mdl"

-- 消耗的食物弹药类型：香蕉
SWEP.Primary.Ammo = "foodbanana"

-- 食用回复的生命值
SWEP.FoodHealth = 10
-- 食用所需时间（秒）
SWEP.FoodEatTime = 2.75
