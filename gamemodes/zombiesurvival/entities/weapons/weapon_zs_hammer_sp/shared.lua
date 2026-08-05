-- ============================================================================
-- weapon_zs_hammer_sp/shared.lua - 锤子 SP（共享）：近战维修武器属性
-- 负责：近战/修复参数、音效、攻击冷却与武器修饰符
-- ============================================================================
SWEP.Base = "weapon_zs_basemelee" -- 基于基础近战武器

SWEP.PrintName = ""..translate.Get("weapon_zs_hammer_sp") -- 显示名称
SWEP.Description = ""..translate.Get("weapon_zs_hammer_description_sp") -- 描述文本

SWEP.DamageType = DMG_CLUB -- 伤害类型：钝击

SWEP.ViewModel = "models/weapons/v_hammer/c_hammer.mdl" -- 第一人称模型
SWEP.WorldModel = "models/weapons/w_hammer.mdl" -- 第三人称模型
SWEP.UseHands = true -- 使用玩家手臂

SWEP.Primary.ClipSize = 1 -- 弹匣容量
SWEP.Primary.Automatic = true -- 自动攻击
SWEP.Primary.Ammo = "GaussEnergy" -- 弹药类型
SWEP.Primary.Delay = 0.9 -- 攻击间隔
SWEP.Primary.DefaultClip = 16 -- 默认弹药

SWEP.Secondary.ClipSize = 1 -- 副弹匣容量
SWEP.Secondary.DefaultClip = 1 -- 副默认弹药
SWEP.Secondary.Ammo = "dummy" -- 副弹药类型（占位）

--SWEP.MeleeDamage = 35 -- Reduced due to instant swing speed
SWEP.MeleeDamage = 30 -- 近战伤害
SWEP.MeleeRange = 90 -- 近战范围
SWEP.MeleeSize = 0.875 -- 近战判定大小

SWEP.MaxStock = 5 -- 最大库存数量

SWEP.UseMelee1 = true -- 使用近战模式 1

SWEP.NoPropThrowing = true -- 禁止投掷物品

SWEP.HitGesture = ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE -- 命中手势
SWEP.MissGesture = SWEP.HitGesture -- 未命中手势复用命中手势

SWEP.HealStrength = 3 -- 修理时的回复强度

SWEP.NoHolsterOnCarry = true -- 搬运时不允许收起武器

SWEP.NoGlassWeapons = true -- 不是玻璃武器

SWEP.AllowQualityWeapons = true -- 允许强化

-- 武器修饰符：降低开火延迟、增加近战范围
GAMEMODE:SetPrimaryWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.04)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_MELEE_RANGE, 3, 1)

-- ==== SetNextAttack - 根据攻速倍率设置下次攻击时间 ====
function SWEP:SetNextAttack()
	local owner = self:GetOwner()
	local armdelay = owner:GetMeleeSpeedMul() -- 玩家近战攻速倍率
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay * (owner.HammerSwingDelayMul or 1) * armdelay)
end

-- ==== PlayHitSound - 命中音效 ====
function SWEP:PlayHitSound()
	self:EmitSound("weapons/melee/crowbar/crowbar_hit-"..math.random(4)..".ogg", 75, math.random(110, 115))
end

-- ==== PlayRepairSound - 修理目标时的音效 ====
function SWEP:PlayRepairSound(hitent)
	hitent:EmitSound("npc/dog/dog_servo"..math.random(7, 8)..".wav", 70, math.random(100, 105))
end
