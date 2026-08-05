-- ============================================================================
-- weapon_zs_f_water.lua - 瓶装水食物武器
-- 负责：水的可食用属性（回复量、食用耗时、液体判定）与水瓶的第一/第三人称模型
-- ============================================================================
AddCSLuaFile()

-- 基于食物武器基础
SWEP.Base = "weapon_zs_basefood"

-- 显示名称
SWEP.PrintName = ""..translate.Get("weapon_zs_f_water")

if CLIENT then
	-- 手指骨骼微调（握持水瓶的姿势修正）
	SWEP.ViewModelBoneMods = {
		["ValveBiped.Bip01_R_Finger02"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 59, 0) },
	}

	-- 第一人称手持水瓶模型
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props/cs_office/water_bottle.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4, 2, -1), angle = Angle(0, -90, 180), size = Vector(0.75, 0.75, 0.75), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 第三人称水瓶模型
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props/cs_office/water_bottle.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4, 2, -1), angle = Angle(0, -90, 180), size = Vector(0.75, 0.75, 0.75), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 第一人称骨架模型（手雷模型占位）
SWEP.ViewModel = "models/weapons/c_grenade.mdl"
-- 第三人称模型：水瓶
SWEP.WorldModel = "models/props/cs_office/water_bottle.mdl"

-- 食用消耗的弹药类型
SWEP.Primary.Ammo = "foodwater"

-- 食用回复的生命值
SWEP.FoodHealth = 5
-- 食用所需时间（秒）
SWEP.FoodEatTime = 2
-- 液体食物（对应饮水音效/吞咽表现）
SWEP.FoodIsLiquid = true
