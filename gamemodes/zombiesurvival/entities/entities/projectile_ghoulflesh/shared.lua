-- ============================================================================
-- projectile_ghoulflesh/shared.lua - 食尸鬼腐肉投射物（共享定义）
-- 负责：定义腐肉投掷物：飞行中直接穿过亡灵玩家（不对友军生效），
--       只作用于人类目标
-- ============================================================================
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞豁免：亡灵玩家直接穿过 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_UNDEAD
end
