-- ============================================================================
-- weapon_zs_keyboard.lua - 键盘（搞笑风格近战武器，可格挡）
-- 负责：SCK 拼装外观（键盘模型+手指骨骼调整）、近战数值、格挡姿态与
--       塑料音效、开火延迟修饰器
-- ============================================================================

-- 共享文件：客户端也需要下载本文件
AddCSLuaFile()

-- 武器显示名（走翻译表）
SWEP.PrintName = ""..translate.Get("weapon_zs_keyboard")

-- 客户端专属属性（SCK 视图/世界模型元素）
if CLIENT then
	-- 视图模型视场角与翻转设置
	SWEP.ViewModelFOV = 55
	SWEP.ViewModelFlip = false

	-- 隐藏原始视图/世界模型（外观由 SCK 元素拼装）
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false

	-- 视图模型骨骼修改：调整右手两指弯曲角度（做出"持键盘"手势）
	SWEP.ViewModelBoneMods = {
		["ValveBiped.Bip01_R_Finger02"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -45.715, 0) },
		["ValveBiped.Bip01_R_Finger01"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -49.524, 0) }
	}
	-- SCK 视图模型元素：手持的键盘模型
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_c17/computer01_keyboard.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.091, 4.4, -7.728), angle = Angle(180, -82.842, 80.794), size = Vector(0.75, 0.75, 0.75), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	-- SCK 世界模型元素：第三人称下的键盘外观
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_c17/computer01_keyboard.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 4.091, -8.636), angle = Angle(180, -60.341, 90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 继承近战武器基类
SWEP.Base = "weapon_zs_basemelee"

-- 持枪姿势（单手握持近战姿势）
SWEP.HoldType = "melee"

-- 伤害类型：钝器打击
SWEP.DamageType = DMG_CLUB

-- 使用警棍模型作为持握骨架
SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel = "models/props_c17/computer01_keyboard.mdl"
SWEP.UseHands = true

-- 近战数值：35 伤害、52 距离、1.25 判定尺寸
SWEP.MeleeDamage = 35
SWEP.MeleeRange = 52
SWEP.MeleeSize = 1.25

-- 主攻击间隔 0.75 秒
SWEP.Primary.Delay = 0.75

-- 挥砍动画参数：0.3 秒挥击时间、旋转与偏移（持手雷姿势挥动）
SWEP.SwingTime = 0.3
SWEP.SwingRotation = Angle(30, -30, -30)
SWEP.SwingOffset = Vector(0, -30, 0)
SWEP.SwingHoldType = "grenade"

-- 允许武器强化；拆除效率（道具拆解速度倍率）
SWEP.AllowQualityWeapons = true
SWEP.DismantleDiv = 2

-- 格挡（防守）姿态下的键盘位置与角度
SWEP.BlockPos = Vector(-13.867, -8.54, 7.62)
SWEP.BlockAng = Angle(5.133, 3.448, -57.561)

-- 格挡音效与音调（随机塑料撞击声）
SWEP.BlockSoundPitch  = math.random(70,90)
SWEP.BlockSound = "physics/plastic/plastic_barrel_impact_bullet"..math.random(3)..".wav"

-- 武器强化修饰器：开火延迟 -0.075 秒
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.075)

-- ==== PlayHitSound - 命中音效（键盘按键敲击声） ====
function SWEP:PlayHitSound()
	self:EmitSound("weapons/melee/keyboard/keyboard_hit-0"..math.random(4)..".ogg")
end
