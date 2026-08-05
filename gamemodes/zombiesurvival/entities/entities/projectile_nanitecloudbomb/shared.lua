-- ============================================================================
-- projectile_nanitecloudbomb/shared.lua - 纳米云炸弹投射物实体（共享端）
-- 负责：定义碰撞过滤规则（只碰撞僵尸与场景）
-- ============================================================================

ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞过滤 ====
-- 飞行中不碰撞人类玩家（避免误伤与提前引爆）
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_HUMAN
end
