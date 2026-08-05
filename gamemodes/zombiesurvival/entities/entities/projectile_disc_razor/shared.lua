-- ============================================================================
-- projectile_disc_razor/shared.lua - 飞盘锯刃投射物（共享）
-- 负责：定义实体类型与碰撞豁免规则（不与玩家/其他投射物/僵尸建筑碰撞），
--       并预缓存锯刃模型
-- ============================================================================
-- 实体类型为动画实体
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞豁免：玩家、其他投射物与僵尸建筑均不阻挡 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() or ent:IsProjectile() or ent.ZombieConstruction
end

-- 预缓存锯刃模型，避免运行时加载卡顿
util.PrecacheModel("models/props_junk/sawblade001a.mdl")
