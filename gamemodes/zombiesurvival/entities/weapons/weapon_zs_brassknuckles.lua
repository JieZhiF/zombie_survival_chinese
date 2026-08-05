-- ============================================================================
-- weapon_zs_brassknuckles.lua - 黄铜指虎（近战武器）
-- 负责：定义基于拳头的近战属性——双手指虎 SCK 模型外观、极快移动速度、
--       较高近战伤害，并附加攻击间隔缩减强化修饰符
-- ============================================================================
-- 全端加载（服务端 + 客户端）
AddCSLuaFile()

-- 继承自拳头武器基类
SWEP.Base = "weapon_zs_fists"

-- 武器显示名称与描述（本地化文本）
SWEP.PrintName = ""..translate.Get("weapon_zs_brassknuckles")
SWEP.Description = ""..translate.Get("weapon_zs_brassknuckles_description")

if CLIENT then
	-- 第一人称镜头视野
	SWEP.ViewModelFOV = 52
	-- 不翻转视图模型
	SWEP.ViewModelFlip = false

	-- 隐藏默认模型（改用下方自定义指虎部件）
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false

	-- 第一人称部件：右手食指上的指虎
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_c17/utilityconnecter005.mdl", bone = "ValveBiped.Bip01_R_Finger2", rel = "", pos = Vector(1.129, -0.087, 0.4), angle = Angle(0, 15.421, 94.749), size = Vector(0.458, 0.349, 0.395), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		-- 第一人称部件：左手食指上的指虎
		["base+"] = { type = "Model", model = "models/props_c17/utilityconnecter005.mdl", bone = "ValveBiped.Bip01_L_Finger2", rel = "", pos = Vector(1.238, 0.136, -0.399), angle = Angle(2.473, 1.322, 83.697), size = Vector(0.458, 0.349, 0.395), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 第三人称部件：右手上的指虎
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_c17/utilityconnecter005.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.021, 1.006, 0), angle = Angle(0, -93.675, 100), size = Vector(0.458, 0.349, 0.395), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		-- 第三人称部件：左手上的指虎
		["base+"] = { type = "Model", model = "models/props_c17/utilityconnecter005.mdl", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(4.085, 0.674, 0), angle = Angle(0, -99.708, 82.794), size = Vector(0.458, 0.349, 0.395), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 持枪移动速度（最快）
SWEP.WalkSpeed = SPEED_FASTEST

-- 第一人称/第三人称模型（借用公民手臂与手雷模型）
SWEP.ViewModel = "models/weapons/c_arms_citizen.mdl"
SWEP.WorldModel	= "models/weapons/w_grenade.mdl"

-- 武器在武器栏中的权重
SWEP.Weight = 4

-- 近战伤害
SWEP.MeleeDamage = 22.5

-- 不是徒手状态（拥有实体武器）
SWEP.Unarmed = false

-- 允许丢弃/显示拾取提示/允许拆除
SWEP.Undroppable = false
SWEP.NoPickupNotification = false
SWEP.NoDismantle = false

-- 不是玻璃武器
SWEP.NoGlassWeapons = false

-- 允许强化（品质升级）
SWEP.AllowQualityWeapons = true

-- 附加武器强化修饰符：攻击间隔缩减 0.06 秒
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.06)
