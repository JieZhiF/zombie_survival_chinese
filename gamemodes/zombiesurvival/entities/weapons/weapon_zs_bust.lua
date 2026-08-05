-- ============================================================================
-- weapon_zs_bust.lua - 布林雕像（布林雕像近战武器）
-- 负责：手持石像挥击的近战武器属性、挥击/命中音效、格挡设置
-- ============================================================================
-- 注册为共享文件（客户端与服务端都加载）
AddCSLuaFile()

-- 武器名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_bust")

if CLIENT then
	-- 客户端专属：第一人称视野与模型翻转设置
	SWEP.ViewModelFOV = 70
	SWEP.ViewModelFlip = false

	-- 仅显示第一人称模型，隐藏世界模型（使用自定义附加模型代替）
	SWEP.ShowViewModel = true
	SWEP.ShowWorldModel = false

	-- 第一人称附加模型：雕像主体（绑定右手）
	SWEP.VElements = {
		["base"] = { type = "Model", model = "models/props_combine/breenbust.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(6, -2, -17), angle = Angle(180, 0, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["stick"] = { type = "Model", model = "models/props_docks/dock01_pole01a_128.mdl", bone = "ValveBiped.Bip01", rel = "base", pos = Vector(3.25, 3.194, -20.932), angle = Angle(5, 0, 0), size = Vector(0.15, 0.15, 0.15), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}

	-- 第三人称附加模型：雕像主体与手持木棍
	SWEP.WElements = {
		["base"] = { type = "Model", model = "models/props_combine/breenbust.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(0, 1, -20), angle = Angle(180, 270, 0), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
		["stick"] = { type = "Model", model = "models/props_docks/dock01_pole01a_128.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "base", pos = Vector(0, -3, -18), angle = Angle(0, 0, 0), size = Vector(0.1, 0.1, 0.1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
	}
end

-- 继承近战武器基础
SWEP.Base = "weapon_zs_basemelee"

-- 伤害类型：钝击（棍棒类）
SWEP.DamageType = DMG_CLUB

-- 第一人称 / 第三人称模型
SWEP.ViewModel = "models/weapons/c_crowbar.mdl"
SWEP.WorldModel = Model("models/props_combine/breenbust.mdl")
-- 使用玩家自己的手臂模型
SWEP.UseHands = true

-- 近战伤害 / 攻击距离 / 攻击判定范围
SWEP.MeleeDamage = 50
SWEP.MeleeRange = 50
SWEP.MeleeSize = 1.4

-- 禁用基础近战攻击方式（改用自定义挥击）
SWEP.UseMelee1 = false

-- 命中 / 挥空时的动作手势
SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
SWEP.MissGesture = SWEP.HitGesture

-- 挥击时模型旋转角度 / 挥击动画时长 / 挥击时的持枪姿势
SWEP.SwingRotation = Angle(30, -30, -30)
SWEP.SwingTime = 0.3
SWEP.SwingHoldType = "grenade"


-- 格挡时模型位置与角度偏移
SWEP.BlockPos = Vector(-12.19, -8.29, 2.319)
SWEP.BlockAng = Angle(10.732, -4.687, -46.086)

-- 格挡减伤倍率（默认值 / 实际使用值）
SWEP.DefendingDamageBlockedDefault = 1.7
SWEP.DefendingDamageBlocked = 1.7

-- 格挡音效音调
SWEP.BlockSoundPitch  = 110


-- 允许强化（武器升级）
SWEP.AllowQualityWeapons = true

-- 强化词条：攻击间隔 -0.1 秒 / 近战距离 +2
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.1, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_RANGE, 2, 1)

-- 武器等级（Tier 2）
SWEP.Tier = 2
-- 拆除武器时返还的物资比例
SWEP.DismantleDiv = 2

-- ==== PlaySwingSound - 播放挥击音效（低频闷响） ====
function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.Rand(35, 45))
end

-- ==== PlayHitSound - 播放命中硬物音效 ====
function SWEP:PlayHitSound()
	self:EmitSound("physics/concrete/rock_impact_hard"..math.random(6)..".wav", 75, math.Rand(86, 90))
end

-- ==== PlayHitFleshSound - 播放命中肉体音效（硬物撞击 + 身体碎裂声） ====
function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/concrete/rock_impact_hard"..math.random(6)..".wav", 75, math.Rand(86, 90))
	self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav", 75, math.Rand(86, 90))
end


