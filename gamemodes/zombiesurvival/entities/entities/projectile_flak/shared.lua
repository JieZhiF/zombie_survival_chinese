-- ============================================================================
-- projectile_flak/shared.lua - 防空炮弹（高射炮）投射物（共享）
-- 负责：定义实体类型与碰撞豁免规则（不阻挡玩家/其他投射物/僵尸建筑）
-- ============================================================================
-- 实体类型为动画实体
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞豁免：玩家、其他投射物与僵尸建筑均不阻挡 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() or ent:IsProjectile() or ent.ZombieConstruction
end
