-- ============================================================================
-- weapon_zs_f_soda.lua - 苏打水（食物/饮品）
-- 负责：可饮用食物武器，恢复少量生命值，客户端拼装易拉罐模型
-- ============================================================================
AddCSLuaFile()

SWEP.Base = "weapon_zs_basefood" -- 继承食物武器基类

SWEP.PrintName = ""..translate.Get("weapon_zs_f_soda") -- 武器显示名称

if CLIENT then
	-- 调整持物时手指弯曲角度，模拟握住易拉罐
	SWEP.ViewModelBoneMods = {
		["ValveBiped.Bip01_R_Finger02"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 59, 0) },
	}

	-- 第一人称模型部件（易拉罐，挂在右手骨骼）
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_junk/popcan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4, 2, -1), angle = Angle(0, -90, 180), size = Vector(0.75, 0.75, 0.75), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 第三人称模型部件（易拉罐，挂在右手骨骼）
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_junk/popcan01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4, 2, -1), angle = Angle(0, -90, 180), size = Vector(0.75, 0.75, 0.75), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.ViewModel = "models/weapons/c_grenade.mdl" -- 第一人称模型
SWEP.WorldModel = "models/props_junk/popcan01a.mdl" -- 第三人称模型（易拉罐）

SWEP.Primary.Ammo = "foodsoda" -- 消耗的弹药类型（食物苏打）

SWEP.FoodHealth = 5 -- 饮用恢复的生命值
SWEP.FoodEatTime = 2 -- 饮用耗时（秒）
SWEP.FoodIsLiquid = true -- 属于液态饮品（可边走边喝）
