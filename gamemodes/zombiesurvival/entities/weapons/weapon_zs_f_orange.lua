-- ============================================================================
-- weapon_zs_f_orange.lua - 橙子（食物类武器）
-- 负责：定义可食用橙子的属性——SCK 自定义模型外观、消耗橙子食物弹药、
--       食用恢复生命与所需时间
-- ============================================================================
-- 全端加载（服务端 + 客户端）
AddCSLuaFile()

-- 继承自基础食物武器
SWEP.Base = "weapon_zs_basefood"

-- 武器显示名称（本地化文本）
SWEP.PrintName = ""..translate.Get("weapon_zs_f_orange")

if CLIENT then
	-- 第一人称视图模型部件：手持橙子模型
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props/cs_italy/orange.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 2.5, -1), angle = Angle(0, 0, 0), size = Vector(0.6, 0.6, 0.6), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 第三人称世界模型部件：他人视角手持橙子模型
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props/cs_italy/orange.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4, 2.5, -1), angle = Angle(0, 0, 0), size = Vector(0.6, 0.6, 0.6), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 第一人称/第三人称模型（借用手雷与橙子模型）
SWEP.ViewModel = "models/weapons/c_grenade.mdl"
SWEP.WorldModel = "models/props/cs_italy/orange.mdl"

-- 消耗的弹药类型（橙子食物）
SWEP.Primary.Ammo = "foodorange"

-- 食用恢复的生命值
SWEP.FoodHealth = 10
-- 食用所需时间（秒）
SWEP.FoodEatTime = 2.75
