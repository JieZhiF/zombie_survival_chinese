-- ============================================================================
-- shared.lua - 重装兵投射物（共享）
-- 负责：定义投射物基础类型与碰撞过滤规则（对人类队友与其它投射物不碰撞）
-- ============================================================================
-- 基于 anim 实体类型
ENT.Type = "anim"
-- 子弹不可命中此投射物
ENT.IgnoreBullets = true

-- ==== ShouldNotCollide - 碰撞过滤 ====
-- 不与人类阵营玩家及其它投射物发生碰撞（避免误伤队友/误触发爆炸）
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_HUMAN or ent:IsProjectile()
end
