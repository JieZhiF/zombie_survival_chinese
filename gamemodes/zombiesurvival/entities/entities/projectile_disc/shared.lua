-- ============================================================================
-- shared.lua - 电光飞盘投射物（共享）：声明实体类型与碰撞过滤
-- 负责：定义飞盘不碰撞任何玩家（可穿人飞行），并预缓存飞盘模型
-- ============================================================================
-- 动画实体类型（物理投射物）
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞过滤：飞盘可穿过所有玩家 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer()
end

-- 预缓存电光飞盘模型（锯片模型）
util.PrecacheModel("models/props_junk/sawblade001a.mdl")
