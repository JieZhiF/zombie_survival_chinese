-- ============================================================================
-- weapon_zs_medicgun/init.lua - 治疗枪（服务端入口）
-- 负责：指定发射的治疗飞镖投射物，并在生成时赋予追踪目标、治疗量与增益时长
-- ============================================================================
INC_SERVER()

-- 发射的投射物实体：治疗飞镖，初速度 2000 单位/秒
SWEP.Primary.Projectile = "projectile_healdart"
SWEP.Primary.ProjVelocity = 2000

-- ==== EntModify - 投射物生成前修改：设置追踪目标、治疗量（受主人技能加成）与增益时长 ====
function SWEP:EntModify(ent)
	local owner = self:GetOwner()

	ent:SetSeeked(self:GetSeekedPlayer() or nil)
	ent.Heal = self.Heal * (owner.MedDartEffMul or 1)
	ent.BuffDuration = self.BuffDuration
end