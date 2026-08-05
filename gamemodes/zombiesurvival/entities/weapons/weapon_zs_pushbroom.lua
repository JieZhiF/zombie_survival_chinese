-- ============================================================================
-- weapon_zs_pushbroom.lua - 扫把近战武器（劳工加成）
-- 负责：扫把近战数值（伤害随劳工时间成长）、挥击/格挡参数与音效
-- ============================================================================
AddCSLuaFile()

-- 显示名称与描述
SWEP.PrintName = ""..translate.Get("weapon_zs_pushbroom")
SWEP.Description = ""..translate.Get("weapon_zs_pushbroom_description")

if CLIENT then
	SWEP.ViewModelFOV = 70

	-- 隐藏原生模型，全部由拼装件构成
	SWEP.ShowViewModel = false
	SWEP.ShowWorldModel = false

	-- 第一人称扫把模型
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_c17/pushbroom.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(5, 0.5, 8), angle = Angle(-65, -90, 90), size = Vector(0.75, 0.75, 0.75), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
	-- 第三人称扫把模型
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_c17/pushbroom.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(3, 1, 5), angle = Angle(247, 90, 283), size = Vector(0.75, 0.75, 0.75), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

SWEP.Base = "weapon_zs_basemelee"

-- 持枪姿势
SWEP.HoldType = "melee2"

-- 伤害类型：钝器
SWEP.DamageType = DMG_CLUB

-- 模型与手臂
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.UseHands = true

-- 近战数值（伤害随劳工时间成长）
SWEP.MeleeDamage = 53 * GAMEMODE.LabourTime
SWEP.MeleeRange = 67
SWEP.MeleeSize = 1.7
SWEP.MeleeKnockBack = 90

-- 攻击间隔
SWEP.Primary.Delay = 1.05

-- 武器等级
SWEP.Tier = 2

-- 移动速度
SWEP.WalkSpeed = SPEED_FAST

-- 挥击动画参数
SWEP.SwingRotation = Angle(0, -90, -60)
SWEP.SwingOffset = Vector(0, 30, -40)
SWEP.SwingTime = 0.6
SWEP.SwingHoldType = "melee"

-- 可强化；拆除收益减半
SWEP.AllowQualityWeapons = true
SWEP.DismantleDiv = 2

-- 格挡动画位置
SWEP.BlockPos = Vector(3, -5, -2)
SWEP.BlockAng = Angle(0, 20, -25)

-- 格挡减伤倍率
SWEP.DefendingDamageBlocked = 1.85
SWEP.DefendingDamageBlockedDefault = 1.85
-- 强化：攻击间隔缩短 + 近战范围扩大
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.08, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_RANGE, 3, 1)

-- ==== PlaySwingSound - 挥击音效 ====
function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 80, math.Rand(60, 65))
end

-- ==== PlayHitSound - 命中音效（木质） ====
function SWEP:PlayHitSound()
	self:EmitSound("physics/wood/wood_plank_impact_hard"..math.random(4)..".wav", 75, math.random(75, 80))
end

-- ==== PlayHitFleshSound - 命中肉体音效（木质） ====
function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/wood/wood_plank_impact_hard"..math.random(4)..".wav", 75, math.random(75, 80))
end
