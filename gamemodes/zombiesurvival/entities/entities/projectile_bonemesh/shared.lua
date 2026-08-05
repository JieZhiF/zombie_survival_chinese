-- ============================================================================
-- projectile_bonemesh/shared.lua - 骨网投射物（共享部分）
-- 负责：定义骨网武器（weapon_zs_bonemesh）发射的骨块投射物，
--       设置碰撞过滤规则（穿透僵尸玩家，仅撞击人类与场景），
--       并预缓存骨块模型
-- ============================================================================

-- 实体类型：动画实体（投射物）
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞过滤规则 ====
-- 僵尸玩家不参与碰撞（骨网穿过僵尸，仅命中人类目标）
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_UNDEAD
end

-- 预缓存骨块模型，避免运行时卡顿
util.PrecacheModel("models/Gibs/HGIBS.mdl")
