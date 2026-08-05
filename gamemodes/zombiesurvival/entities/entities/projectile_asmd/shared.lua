-- ============================================================================
-- projectile_asmd/shared.lua - ASMD 能量弹投射物（共享定义）
-- 负责：定义 ASMD 步枪的能量弹：可被子弹击中（用于二次引爆），
--       飞行中穿过人类玩家与其他投射物
-- ============================================================================
ENT.Type = "anim"
-- 始终与子弹碰撞：被子弹命中时触发引爆机制
ENT.AlwaysImpactBullets = true

-- ==== ShouldNotCollide - 碰撞豁免：人类玩家与其他投射物直接穿过 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_HUMAN or ent:IsProjectile()
end
