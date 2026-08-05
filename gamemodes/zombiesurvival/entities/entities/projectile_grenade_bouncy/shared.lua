-- ============================================================================
-- shared.lua - 弹跳手雷投射物（共享）：声明实体类型与碰撞过滤
-- 负责：定义弹跳手雷的碰撞规则（人类不受阻挡）并预缓存模型
-- ============================================================================
-- 动画实体类型（带物理模拟的投射物）
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞过滤：人类玩家不阻挡手雷飞行 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_HUMAN
end

-- 预缓存直升机炸弹模型资源，避免运行时卡顿
util.PrecacheModel("models/combine_helicopter/helicopter_bomb01.mdl")
