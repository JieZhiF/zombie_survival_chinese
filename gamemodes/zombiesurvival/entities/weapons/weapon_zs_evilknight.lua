-- ============================================================================
-- weapon_zs_evilknight.lua - 僵尸近战武器「邪恶骑士」（Evil Knight）
-- 负责：定义僵尸骑士刀的伤害、攻击延迟与对玩家/物件的伤害切换机制
-- ============================================================================

AddCSLuaFile()

-- 继承屠夫刀（butcherknife）基础模板
SWEP.Base = "weapon_zs_butcherknife"

-- 仅僵尸可使用
SWEP.ZombieOnly = true
-- 近战伤害 32，并记录原始伤害用于命中后恢复
SWEP.MeleeDamage = 32
SWEP.OriginalMeleeDamage = SWEP.MeleeDamage
-- 攻击间隔 0.32 秒
SWEP.Primary.Delay = 0.32

-- ==== OnMeleeHit - 命中回调：命中非玩家目标时降低伤害 ====
function SWEP:OnMeleeHit(hitent, hitflesh, tr)
	-- 对非玩家目标（场景物件）改用 20 点伤害
	if not hitent:IsPlayer() then
		self.MeleeDamage = 20
	end
end

-- ==== PostOnMeleeHit - 命中结算后恢复原始伤害 ====
function SWEP:PostOnMeleeHit(hitent, hitflesh, tr)
	self.MeleeDamage = self.OriginalMeleeDamage
end

-- ==== SetNextAttack - 根据玩家的近战速度加成设定下次攻击时间 ====
function SWEP:SetNextAttack()
	local owner = self:GetOwner()
	local armdelay = owner:GetMeleeSpeedMul()
	-- 攻击间隔受玩家近战速度倍率影响（越快间隔越短）
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay * armdelay)
end