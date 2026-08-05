-- ============================================================================
-- projectile_handgrenade/shared.lua - 手雷投射物（共享部分）
-- 负责：定义人类投掷手雷（weapon_zs_handgrenade）的投射物，
--       设置碰撞过滤规则（穿透人类玩家，避免炸到自己人后即爆），
--       并预缓存手雷模型
-- ============================================================================

-- 实体类型：动画实体（投射物）
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞过滤规则 ====
-- 人类玩家不参与碰撞（手雷穿过友军继续飞行，仅撞击场景与僵尸）
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_HUMAN
end

-- 预缓存手雷模型，避免运行时卡顿
util.PrecacheModel("models/combine_helicopter/helicopter_bomb01.mdl")
