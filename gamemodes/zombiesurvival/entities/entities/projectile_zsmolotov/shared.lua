-- ============================================================================
-- projectile_zsmolotov/shared.lua - 燃烧瓶投射物（共享）
-- 负责：定义实体类型与碰撞豁免规则（不阻挡人类玩家，防止误伤投掷者）
-- ============================================================================
-- 实体类型为动画实体
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞豁免：与人类玩家不发生碰撞 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_HUMAN
end
