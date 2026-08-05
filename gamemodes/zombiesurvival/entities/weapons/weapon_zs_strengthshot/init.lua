-- ============================================================================
-- weapon_zs_strengthshot/init.lua - 力量射击（医疗工具）
-- 负责：指定发射的力量镖弹体，并在生成时传递追踪目标与增益时长
-- ============================================================================
INC_SERVER()

-- 发射力量镖弹体
SWEP.Primary.Projectile = "projectile_strengthdart"
-- 弹体飞行速度
SWEP.Primary.ProjVelocity = 2000

-- ==== EntModify - 弹体生成后：传递追踪目标与增益时长 ====
function SWEP:EntModify(ent)
	ent:SetSeeked(self:GetSeekedPlayer() or nil)
	ent.BuffDuration = self.BuffDuration
end
