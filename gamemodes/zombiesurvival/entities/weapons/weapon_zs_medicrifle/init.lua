-- ============================================================================
-- init.lua - 医疗步枪武器服务端逻辑
-- 负责：定义主攻击发射的医疗飞镖投射物（高速），并在生成飞镖时写入
--       追踪目标、治疗量与增益时长
-- ============================================================================
INC_SERVER()

-- 主攻击发射的投射物实体（医疗飞镖）
SWEP.Primary.Projectile = "projectile_medicrifle"
-- 投射物初速度（高速）
SWEP.Primary.ProjVelocity = 3500

-- ==== EntModify - 投射物生成后配置医疗参数 ====
-- 设置飞镖的锁定追踪目标；治疗量受玩家"医疗飞镖强化"加成，并传递增益时长
function SWEP:EntModify(ent)
	local owner = self:GetOwner()

	ent:SetSeeked(self:GetSeekedPlayer() or nil)
	ent.Heal = self.Heal * (owner.MedDartEffMul or 1)
	ent.BuffDuration = self.BuffDuration
end
