-- ============================================================================
-- weapon_zs_fryingpan.lua - 平底锅近战武器
-- 负责：定义平底锅的近战伤害/挥击动画、厨具特性（大厨技能联动）、格挡姿态与命中音效
-- ============================================================================

-- 注册为共享文件（客户端也需加载）
AddCSLuaFile()

-- 武器显示名称
SWEP.PrintName = ""..translate.Get("weapon_zs_fryingpan")

if CLIENT then
	-- 不翻转第一人称模型
	SWEP.ViewModelFlip = false
	-- 第一人称镜头视野
	SWEP.ViewModelFOV = 55

	-- 隐藏第一人称模型本体（外观由附加模型显示）
	SWEP.ShowViewModel = false
	-- 隐藏世界模型本体
	SWEP.ShowWorldModel = false

	-- 第一人称附加模型：手持平底锅
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_c17/metalpot002a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 1.368, -9), angle = Angle(-90, 90, -90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	-- 世界模型附加模型：第三人称手持平底锅
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_c17/metalpot002a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 1.368, -9), angle = Angle(-90, 90, -90), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 母本：近战武器基础
SWEP.Base = "weapon_zs_basemelee"

-- 伤害类型：钝击（棍棒类）
SWEP.DamageType = DMG_CLUB

-- 第一人称模型（电击棒占位，实际隐藏）
SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
-- 世界模型：平底锅
SWEP.WorldModel = "models/props_c17/metalpot002a.mdl"
-- 使用玩家手臂模型
SWEP.UseHands = true

-- 近战伤害
SWEP.MeleeDamage = 40
-- 近战攻击距离
SWEP.MeleeRange = 50
-- 近战攻击范围体积
SWEP.MeleeSize = 1.15

-- 使用第一套近战攻击（普通挥击）
SWEP.UseMelee1 = true

-- 命中时播放的玩家手势
SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
-- 挥空时的手势与命中相同
SWEP.MissGesture = SWEP.HitGesture

-- 挥击动画旋转角度
SWEP.SwingRotation = Angle(30, -30, -30)
-- 挥击动画时长
SWEP.SwingTime = 0.3
-- 挥击时的持枪姿势
SWEP.SwingHoldType = "grenade"

-- 允许武器强化
SWEP.AllowQualityWeapons = true
-- 厨具特性：大厨技能（SKILL_MASTERCHEF）触发烹饪效果
SWEP.Culinary = true

-- 格挡姿态下第一人称模型的位置偏移
SWEP.BlockPos = Vector(-12.19, -8.29, 2.319)
-- 格挡姿态下第一人称模型的旋转角度
SWEP.BlockAng = Angle(10.732, -4.687, -46.086)

-- 默认格挡伤害减免系数（1.1 = 受伤反而…详见母本实现；基础防御值）
SWEP.DefendingDamageBlockedDefault = 1.1
-- 当前格挡伤害减免系数
SWEP.DefendingDamageBlocked = 1.1
-- 格挡时的持枪姿势
SWEP.BlockHoldType = "melee2"
-- 附加武器强化修改器：攻击间隔 -0.1（挥击更快）
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.1)

-- ==== PlayHitSound - 命中音效 ====
function SWEP:PlayHitSound()
	-- 随机播放平底锅命中音（4 种之一）
	self:EmitSound("weapons/melee/frying_pan/pan_hit-0"..math.random(4)..".ogg")
end
