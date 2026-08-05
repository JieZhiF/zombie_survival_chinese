-- ============================================================================
-- weapon_zs_stunbaton.lua - 电击棒（人类近战武器）
-- 负责：定义电击棒的近战伤害、挥击动画与腿部减速效果
-- ============================================================================
AddCSLuaFile()

-- 武器名称与描述（从翻译表读取）
SWEP.PrintName = ""..translate.Get("weapon_zs_stunbaton")
SWEP.Description = ""..translate.Get("weapon_zs_stunbaton_description")

if CLIENT then
	-- 第一人称视野大小
	SWEP.ViewModelFOV = 50
end

-- 基于近战武器母本
SWEP.Base = "weapon_zs_basemelee"

-- 视图模型与第三人称模型（借用警棍模型）
SWEP.ViewModel = "models/weapons/c_stunstick.mdl"
SWEP.WorldModel = "models/weapons/w_stunbaton.mdl"
SWEP.UseHands = true

-- 持握姿势
SWEP.HoldType = "melee"

-- 近战伤害、腿部伤害与攻击距离/判定半径
SWEP.MeleeDamage = 32
SWEP.LegDamage = 20
SWEP.MeleeRange = 49
SWEP.MeleeSize = 1.5
-- 攻击间隔
SWEP.Primary.Delay = 0.9

-- 挥击动画参数：时长、旋转、偏移与持握姿势
SWEP.SwingTime = 0.25
SWEP.SwingRotation = Angle(60, 0, 0)
SWEP.SwingOffset = Vector(0, -50, 0)
SWEP.SwingHoldType = "grenade"

-- 脉冲打击得分倍率
SWEP.PointsMultiplier = GAMEMODE.PulsePointsMultiplier

-- 允许强化
SWEP.AllowQualityWeapons = true

-- 格挡姿势的位置与角度
SWEP.BlockPos = Vector(-12.19, -8.29, 2.319)
SWEP.BlockAng = Angle(10.732, -4.687, -46.086)

-- 格挡伤害减免（默认值/当前值）
SWEP.DefendingDamageBlockedDefault = 1.5
SWEP.DefendingDamageBlocked = 1.5

-- 附加武器修正：攻击间隔 -0.09 秒、腿部伤害 +2
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_FIRE_DELAY, -0.09)
GAMEMODE:AttachWeaponModifier(SWEP, WEAPON_MODIFIER_LEG_DAMAGE, 2)

-- ==== PlaySwingSound - 播放挥击音效 ====
function SWEP:PlaySwingSound()
	self:EmitSound("Weapon_StunStick.Swing")
end

-- ==== PlayHitSound - 播放击中世界的音效 ====
function SWEP:PlayHitSound()
	self:EmitSound("Weapon_StunStick.Melee_HitWorld")
end

-- ==== PlayHitFleshSound - 播放击中血肉的音效 ====
function SWEP:PlayHitFleshSound()
	self:EmitSound("Weapon_StunStick.Melee_Hit")
end

-- ==== OnMeleeHit - 近战命中：对玩家目标附加腿部伤害（脉冲减速） ====
function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	if hitent:IsValid() and hitent:IsPlayer() then
		hitent:AddLegDamageExt(self.LegDamage, self:GetOwner(), self, SLOWTYPE_PULSE)
	end
end
