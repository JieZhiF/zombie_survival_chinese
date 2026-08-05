-- ============================================================================
-- weapon_zs_ladel.lua - 汤勺近战武器
-- 负责：定义汤勺的近战伤害（随劳动时间增长）、挥击动画、厨具特性与命中音效
-- ============================================================================

-- 注册为共享文件（客户端也需加载）
AddCSLuaFile()

-- 武器显示名称
SWEP.PrintName = ""..translate.Get("weapon_zs_ladel")

if CLIENT then
	-- 不翻转第一人称模型
	SWEP.ViewModelFlip = false
	-- 第一人称镜头视野
	SWEP.ViewModelFOV = 60

	-- 隐藏第一人称模型本体（外观由附加模型显示）
	SWEP.ShowViewModel = false
	-- 隐藏世界模型本体
	SWEP.ShowWorldModel = false

	-- 第一人称附加模型：手持汤勺
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_lab/ladel.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.809, 2.072, -6.882), angle = Angle(0.912, -90, 6.249), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 世界模型附加模型：第三人称手持汤勺
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_lab/ladel.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3.009, 1.833, -6.954), angle = Angle(4.703, -180, 4.718), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 母本：近战武器基础
SWEP.Base = "weapon_zs_basemelee"

-- 伤害类型：钝击（棍棒类）
SWEP.DamageType = DMG_CLUB

-- 第一人称模型（撬棍占位，实际隐藏）
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
-- 世界模型
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
-- 使用玩家手臂模型
SWEP.UseHands = true

-- 近战伤害：基础 34 × 游戏模式劳动时间系数（随波次进程成长的伤害）
SWEP.MeleeDamage = 34 * GAMEMODE.LabourTime
-- 近战攻击距离
SWEP.MeleeRange = 58
-- 近战攻击范围体积
SWEP.MeleeSize = 1.15

-- 攻击间隔 0.9 秒
SWEP.Primary.Delay = 0.9

-- 使用第一套近战攻击（普通挥击）
SWEP.UseMelee1 = true

-- 命中时播放的玩家手势
SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
-- 挥空时的手势与命中相同
SWEP.MissGesture = SWEP.HitGesture

-- 挥击动画旋转角度
SWEP.SwingRotation = Angle(30, -30, -30)
-- 挥击动画时长
SWEP.SwingTime = 0.25
-- 挥击时的持枪姿势
SWEP.SwingHoldType = "grenade"

-- 允许武器强化
SWEP.AllowQualityWeapons = true
-- 厨具特性：大厨技能（SKILL_MASTERCHEF）触发烹饪效果
SWEP.Culinary = true

-- 格挡姿态下第一人称模型的位置偏移
SWEP.BlockPos = Vector(-1, -5, -5)
-- 格挡姿态下第一人称模型的旋转角度
SWEP.BlockAng = Angle(0, 20, -25)
-- 附加武器强化修改器：近战攻击距离 +4
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_RANGE, 4)

-- ==== PlayHitSound - 命中音效 ====
function SWEP:PlayHitSound()
	-- 随机播放平底锅命中音（4 种之一），音调 140
	self:EmitSound("weapons/melee/frying_pan/pan_hit-0"..math.random(4)..".ogg", 75, 140)
end
