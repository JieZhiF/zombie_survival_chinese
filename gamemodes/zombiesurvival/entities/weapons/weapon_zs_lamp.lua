-- ============================================================================
-- weapon_zs_lamp.lua - 台灯：近战钝器武器
-- 负责：定义台灯的挥击/格挡属性、挥击动画参数与攻击音效
-- ============================================================================
AddCSLuaFile()

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_lamp")

if CLIENT then
	-- 客户端：第一人称视野与模型翻转
	SWEP.ViewModelFOV = 65
	SWEP.ViewModelFlip = false

	-- 隐藏原模型，改用台灯模型作为手持物（SCK 元素）
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_interiors/Furniture_Lamp01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1.85, -8), angle = Angle(183, 0, 2), size = Vector(1.5, 1.5, 1.5), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	-- 第三人称视图附加元素（台灯模型）
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_interiors/Furniture_Lamp01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.837, 1.638, -10), angle = Angle(180, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 基于近战武器母本
SWEP.Base = "weapon_zs_basemelee"

-- 第一人称（电棍模型）与第三人称模型（台灯），使用玩家手部模型
SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel = "models/props_interiors/Furniture_Lamp01a.mdl"
SWEP.UseHands = true

-- 持握姿势：双手近战
SWEP.HoldType = "melee2"

-- 伤害类型：钝击
SWEP.DamageType = DMG_CLUB

-- 近战伤害 44、攻击距离 68、判定半径 2
SWEP.MeleeDamage = 44
SWEP.MeleeRange = 68
SWEP.MeleeSize = 2

-- 攻击间隔（秒）
SWEP.Primary.Delay = 1

-- 持枪移动速度：慢速
SWEP.WalkSpeed = SPEED_SLOW

-- 挥击动画：旋转角度、位移、时长与持握姿势
SWEP.SwingRotation = Angle(0, -90, -60)
SWEP.SwingOffset = Vector(0, 30, -40)
SWEP.SwingTime = 0.4
SWEP.SwingHoldType = "melee"

-- 格挡时减免的伤害倍率（1.75 = 格挡时受到的伤害为 1/1.75）
SWEP.DefendingDamageBlockedDefault = 1.75
SWEP.DefendingDamageBlocked = 1.75

-- 格挡姿势的位置与角度
SWEP.BlockPos = Vector(-12.19, -8.29, 2.319)
SWEP.BlockAng = Angle(10.732, -4.687, -46.086)

-- 允许强化，拆除倍率 2
SWEP.AllowQualityWeapons = true
SWEP.DismantleDiv = 2

-- 附加攻击间隔强化模组（每级 -0.1 秒）
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.1)

-- ==== PlaySwingSound - 播放挥击破空音效 ====
function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 80, math.Rand(65, 70))
end

-- ==== PlayHitSound - 播放命中硬物（墙体/物体）音效 ====
function SWEP:PlayHitSound()
	self:EmitSound("physics/metal/metal_solid_impact_hard"..math.random(4, 5)..".wav")
end

-- ==== PlayHitFleshSound - 播放命中血肉（敌人）音效 ====
function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav")
end
