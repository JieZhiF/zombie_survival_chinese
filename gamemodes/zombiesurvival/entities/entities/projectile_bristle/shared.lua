-- ============================================================================
-- projectile_bristle/shared.lua - 荆棘投射物（共享部分）
-- 负责：定义锯齿草武器（weapon_zs_bristle）发射的荆棘刺投射物，
--       设置碰撞过滤规则（穿透僵尸玩家），并预缓存模型与命中音效
-- ============================================================================

-- 实体类型：动画实体（投射物）
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞过滤规则 ====
-- 僵尸玩家不参与碰撞（荆棘刺穿过僵尸继续飞行，仅撞击人类与场景）
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_UNDEAD
end

-- 预缓存荆棘刺模型与命中音效，避免运行时卡顿
util.PrecacheModel("models/props_wasteland/dockplank_chunk01d.mdl")
util.PrecacheSound("npc/antlion_grub/squashed.wav")
