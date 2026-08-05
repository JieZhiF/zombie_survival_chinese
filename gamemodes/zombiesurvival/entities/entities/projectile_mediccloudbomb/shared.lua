-- ============================================================================
-- projectile_mediccloudbomb - 医疗云炸弹投射物实体（共享端）
-- 负责：声明实体类型，并定义与人类玩家不碰撞的飞行规则
-- ============================================================================

-- 实体类型：动画实体
ENT.Type = "anim"

-- ==== ShouldNotCollide - 判断目标是否应跳过碰撞：人类玩家与其互不碰撞（可穿越友军飞行） ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_HUMAN
end
