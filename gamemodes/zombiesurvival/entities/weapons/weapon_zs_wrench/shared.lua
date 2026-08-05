-- ============================================================================
-- weapon_zs_wrench/shared.lua - 近战维修工具「扳手」（Wrench）共享端
-- 负责：定义扳手的近战属性、挥动动作与维修强度（治疗建筑）
-- ============================================================================

-- 武器显示名称与描述（由语言文件提供）
SWEP.PrintName = ""..translate.Get("weapon_zs_wrench")
SWEP.Description = ""..translate.Get("weapon_zs_wrench_description")

-- 继承近战武器基础模板
SWEP.Base = "weapon_zs_basemelee"

-- 第一人称与第三人称模型（扳手模型放大 1.5 倍），使用玩家的手部模型
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/props_c17/tools_wrench01a.mdl"
SWEP.ModelScale = 1.5
SWEP.UseHands = true

-- 持枪姿势（近战姿势）
SWEP.HoldType = "melee"

-- 伤害类型：钝器打击
SWEP.DamageType = DMG_CLUB

-- 攻击间隔 0.8 秒；近战伤害 28、距离 50、判定范围 0.875
SWEP.Primary.Delay = 0.8
SWEP.MeleeDamage = 28
SWEP.MeleeRange = 50
SWEP.MeleeSize = 0.875

-- 商店最大库存 5
SWEP.MaxStock = 5

-- 命中与挥空时的动作手势
SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
SWEP.MissGesture = SWEP.HitGesture

-- 挥动动画的旋转/偏移/时长与姿势
SWEP.SwingTime = 0.19
SWEP.SwingRotation = Angle(30, -30, -30)
SWEP.SwingOffset = Vector(0, -30, 0)
SWEP.SwingHoldType = "grenade"

-- 维修强度：每次命中恢复 13 点建筑生命
SWEP.HealStrength = 13

-- 允许强化
SWEP.AllowQualityWeapons = true

-- 附加武器改造：攻击间隔 -0.04 秒（主槽位）；近战距离 +3（副槽位）
GAMEMODE:SetPrimaryWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.04)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_RANGE, 3, 1)

-- ==== PlayHitSound - 播放击中金属音效 ====
function SWEP:PlayHitSound()
	self:EmitSound("weapons/melee/crowbar/crowbar_hit-"..math.random(4)..".ogg", 75, math.random(120, 125))
end
