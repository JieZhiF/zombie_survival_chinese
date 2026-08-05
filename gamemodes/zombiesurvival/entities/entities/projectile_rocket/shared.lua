-- ============================================================================
-- shared.lua - 火箭投射物（共享）
-- 负责：定义投射物类型与碰撞过滤规则，并预缓存火箭模型
-- ============================================================================
-- 基于 anim 实体类型
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞过滤 ====
-- 不与人类阵营玩家碰撞，避免火箭穿过队友或提前引爆
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_HUMAN
end

-- 预缓存火箭模型，避免首次发射时卡顿
util.PrecacheModel("models/weapons/w_missile_closed.mdl")
