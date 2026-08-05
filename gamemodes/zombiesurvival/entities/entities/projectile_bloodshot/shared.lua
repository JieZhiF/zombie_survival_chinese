-- ============================================================================
-- projectile_bloodshot/shared.lua - 血弹（共享）
-- 负责：声明实体类型与爆炸半径，碰撞过滤（血弹不碰撞任何玩家，穿透后爆炸）
-- ============================================================================
ENT.Type = "anim"

-- 爆炸影响半径（单位）
ENT.Radius = 75

-- ==== ShouldNotCollide - 碰撞过滤：血弹直接穿过所有玩家 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer()
end
