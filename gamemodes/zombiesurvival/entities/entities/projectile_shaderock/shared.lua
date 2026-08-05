-- ============================================================================
-- projectile_shaderock/shared.lua - 暗影石块投射物（共享）
-- 负责：幽影僵尸抛出的石块投射物——声明实体类型与碰撞过滤：免疫子弹/
--       近战/射线检测，直接穿过僵尸玩家与其他投射物；预缓存石块模型
-- ============================================================================

-- 动画实体类型（飞行物）
ENT.Type = "anim"

-- 免疫子弹、近战与玩家射线检测（石块本体不受常规武器影响）
ENT.IgnoreBullets = true
ENT.IgnoreMelee = true
ENT.IgnoreTraces = true

-- ==== ShouldNotCollide - 碰撞过滤：穿过僵尸玩家与其他投射物 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_UNDEAD or ent:IsProjectile()
end

-- 预缓存石块模型（对应 Initialize 中使用的模型）
util.PrecacheModel("models/props_wasteland/rockgranite03b.mdl")
