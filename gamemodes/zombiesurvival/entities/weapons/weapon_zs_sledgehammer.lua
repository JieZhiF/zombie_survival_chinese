-- ============================================================================
-- weapon_zs_sledgehammer.lua - 大铁锤（重型钝击近战武器）
-- 负责：定义高伤害重击属性、格挡（右键）属性与命中音效
-- ============================================================================

-- 客户端共享加载声明（本文件双端加载）
AddCSLuaFile()

-- 武器显示名称（本地化）
SWEP.PrintName = ""..translate.Get("weapon_zs_sledgehammer")
-- 武器商店中的描述文本（本地化）
SWEP.Description = ""..translate.Get("weapon_zs_sledgehammer_description")

-- 客户端专用属性：镜头视野
if CLIENT then
	SWEP.ViewModelFOV = 75
end

-- 继承近战武器基类
SWEP.Base = "weapon_zs_basemelee"

-- 持握姿势：近战二号（大锤）
SWEP.HoldType = "melee2"

-- 伤害类型：钝击
SWEP.DamageType = DMG_CLUB

-- 第一人称视角模型
SWEP.ViewModel = "models/weapons/v_sledgehammer/c_sledgehammer.mdl"
-- 第三人称世界模型
SWEP.WorldModel = "models/weapons/w_sledgehammer.mdl"
-- 使用玩家手臂模型握持
SWEP.UseHands = true

-- 近战伤害：基础 75 乘劳工时间倍率（与游戏进度相关）
SWEP.MeleeDamage = 75 * GAMEMODE.LabourTime
-- 近战攻击距离
SWEP.MeleeRange = 64
-- 近战攻击判定范围半径
SWEP.MeleeSize = 1.75
-- 近战击退力度
SWEP.MeleeKnockBack = 270

-- 攻击间隔（挥击很慢）
SWEP.Primary.Delay = 1.3

-- 武器等级
SWEP.Tier = 2

-- 手持移动速度（最慢）
SWEP.WalkSpeed = SPEED_SLOWEST

-- 挥击动画的姿态旋转与位移
SWEP.SwingRotation = Angle(60, 0, -80)
SWEP.SwingOffset = Vector(0, -30, 0)
-- 挥击动画时长
SWEP.SwingTime = 0.75
-- 挥击时的持握姿势
SWEP.SwingHoldType = "melee"

-- 允许强化（高品质版本）
SWEP.AllowQualityWeapons = true

-- 格挡（右键）时视角模型的位移与旋转
SWEP.BlockPos = Vector(-12.19, -8.29, 2.319)
SWEP.BlockAng = Angle(10.732, -4.687, -46.086)

-- 格挡时减免的伤害（默认值与当前值）
SWEP.DefendingDamageBlockedDefault = 4
SWEP.DefendingDamageBlocked = 4
-- 格挡时的持握姿势
SWEP.BlockHoldType = "slam"
-- 格挡音效的音调（随机）
SWEP.BlockSoundPitch  = math.random(60,80)
-- 格挡音效文件名（随机选择金属撞击声）
local BlockSoundPitch  = "physics/metal/metal_sheet_impact_hard"..math.random(6,8)..".wav"

-- 附加改装：近战判定提前 0.1 秒、攻击冷却缩短 0.1 秒
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_IMPACT_DELAY, -0.1, 1)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.1, 1)

-- ==== PlaySwingSound - 播放挥击音效（低沉的风声） ====
function SWEP:PlaySwingSound()
	self:EmitSound("weapons/iceaxe/iceaxe_swing1.wav", 75, math.random(35, 45))
end

-- ==== PlayHitSound - 播放命中硬物音效 ====
function SWEP:PlayHitSound()
	self:EmitSound("physics/metal/metal_canister_impact_hard"..math.random(3)..".wav", 75, math.Rand(86, 90))
end

-- ==== PlayHitFleshSound - 播放命中肉体音效 ====
function SWEP:PlayHitFleshSound()
	self:EmitSound("physics/body/body_medium_break"..math.random(2, 4)..".wav", 75, math.Rand(86, 90))
end
