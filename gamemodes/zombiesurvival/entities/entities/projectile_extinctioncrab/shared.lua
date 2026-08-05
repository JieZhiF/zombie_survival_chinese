-- ============================================================================
-- projectile_extinctioncrab/shared.lua - 灭绝蟹投射物（共享定义）
-- 负责：声明投射物实体类型、与亡灵阵营玩家的碰撞豁免规则，并预缓存模型
-- ============================================================================

-- 实体类型：动画物理投射物
ENT.Type = "anim"

-- ==== ShouldNotCollide - 与亡灵阵营玩家不碰撞，可穿身飞行 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_UNDEAD
end

-- 预缓存滚动体模型（投射物外观）
util.PrecacheModel("models/roller.mdl")
