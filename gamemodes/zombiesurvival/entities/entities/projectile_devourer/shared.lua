-- ============================================================================
-- shared.lua - 吞噬者投射物（共享）：声明实体类型与碰撞过滤
-- 负责：定义骨刺投射物的碰撞规则（亡灵不受阻挡）并预缓存模型
-- ============================================================================
-- 动画实体类型（带物理模拟的投射物）
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞过滤：亡灵玩家不阻挡骨刺飞行 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_UNDEAD
end

-- 预缓存岩块模型资源，避免运行时卡顿
util.PrecacheModel("models/props_wasteland/rockgranite03b.mdl")
