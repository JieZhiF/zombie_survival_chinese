-- ============================================================================
-- projectile_arrow_mini/shared.lua - 迷你箭矢投射物（共享）
-- 负责：声明 anim 类型投射物，命中结算由服务器处理；共享端定义
--       碰撞豁免规则（穿过人类与其它投射物）
-- ============================================================================
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞豁免：人类玩家与其它投射物不阻挡箭矢 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_HUMAN or ent:IsProjectile()
end
