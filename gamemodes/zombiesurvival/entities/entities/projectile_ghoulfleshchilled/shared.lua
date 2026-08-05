-- ============================================================================
-- projectile_ghoulfleshchilled/shared.lua - 冰冻食尸鬼血肉投射物（共享）
-- 负责：声明投射物类型与碰撞过滤：不与僵尸阵营（友军）玩家碰撞
-- ============================================================================
-- 动画实体类型（由服务器驱动飞行与碰撞）
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞过滤：僵尸阵营玩家直接穿过投射物 ====
function ENT:ShouldNotCollide(ent)
	-- 友军（僵尸阵营）玩家不与投射物发生碰撞，避免误伤友方
	return ent:IsPlayer() and ent:Team() == TEAM_UNDEAD
end
