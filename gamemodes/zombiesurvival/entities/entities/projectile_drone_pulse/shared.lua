-- ============================================================================
-- projectile_drone_pulse/shared.lua - 无人机脉冲弹（共享）
-- 负责：碰撞过滤——穿透玩家、其他投射物与僵尸建筑，直至撞击世界物体
-- ============================================================================
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞过滤：玩家/投射物/僵尸建筑不阻挡脉冲弹 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() or ent:IsProjectile() or ent.ZombieConstruction
end
