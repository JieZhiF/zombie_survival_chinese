-- ============================================================================
-- weapon_zs_stone.lua - 石头（投掷类武器）
-- 负责：手持石块模型显示与投掷参数
-- ============================================================================
-- 注册为共享文件（客户端与服务端都加载）
AddCSLuaFile()

-- 武器名称 / 描述（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_stone")
SWEP.Description = ""..translate.Get("weapon_zs_stone_description")

if CLIENT then
	-- 客户端专属：第一人称模型设置（不翻转、视野 50、只显示第一人称模型）
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 50
	SWEP.ShowViewModel = true
	SWEP.ShowWorldModel = false

	-- 缩小原始手持模型的骨骼（隐藏原模型体积）
	SWEP.ViewModelBoneMods = {
		["ValveBiped.cube1"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["ValveBiped.cube2"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["ValveBiped.cube3"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
		["ValveBiped.cube"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
	}
	-- 第一人称附加模型：右手握着的石头
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_junk/rock001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.091, 3.181, -0.456), angle = Angle(-54.206, 58.294, -50.114), size = Vector(0.492, 0.492, 0.492), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 第三人称附加模型：右手握着的石头
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_junk/rock001a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.181, 2.273, -0.456), angle = Angle(-43.978, 27.614, 70.568), size = Vector(0.379, 0.379, 0.379), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 继承投掷武器基础
SWEP.Base = "weapon_zs_basethrown"

-- 第一人称 / 第三人称模型
SWEP.ViewModel = "models/weapons/c_bugbait.mdl"
SWEP.WorldModel = "models/props_junk/rock001a.mdl"

-- 消耗的弹药类型
SWEP.Primary.Ammo = "stone"

-- 投掷出的投射物实体
SWEP.ThrownProjectile = "projectile_stone"
-- 投掷时的角速度（旋转）/ 初速度
SWEP.ThrowAngVel = 360
SWEP.ThrowVel = 900