-- ============================================================================
-- projectile_poisonflesh - 毒肉投射物实体（共享端）
-- 负责：声明实体类型，并定义与亡灵队伍玩家的碰撞豁免规则
-- ============================================================================

-- 实体类型：动画实体
ENT.Type = "anim"

-- ==== ShouldNotCollide - 判断目标是否应跳过碰撞：亡灵队伍玩家与其互不碰撞 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_UNDEAD
end
