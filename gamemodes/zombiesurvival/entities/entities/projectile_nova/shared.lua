-- ============================================================================
-- projectile_nova/shared.lua - 新星投射物（共享部分）
-- 负责：定义新星炮（weapon_zs_nova）发射的能量球投射物，
--       设置碰撞过滤规则（穿透玩家/其他投射物/僵尸建筑）
-- ============================================================================

-- 实体类型：动画实体（投射物）
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞过滤规则 ====
-- 玩家、其他投射物、僵尸建造物不参与碰撞（能量球直接穿透）
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() or ent:IsProjectile() or ent.ZombieConstruction
end
