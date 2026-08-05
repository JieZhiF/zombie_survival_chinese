-- ============================================================================
-- shared.lua - 幽光球投射物（共享）：声明实体类型与碰撞过滤
-- 负责：定义幽光球的动画实体类型与"穿过僵尸不碰撞"的碰撞规则
-- ============================================================================
-- 动画实体类型（具备物理模拟的投射物）
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞过滤：幽灵能量球直接穿过僵尸 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_UNDEAD
end

-- 预缓存直升机炸弹模型（用于幽光球击中后的爆炸效果资源）
util.PrecacheModel("models/Combine_Helicopter/helicopter_bomb01.mdl")