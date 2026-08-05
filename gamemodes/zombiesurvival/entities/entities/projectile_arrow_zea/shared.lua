-- ============================================================================
-- projectile_arrow_zea - 宙斯（ZEA）电击箭投射物实体（共享端）
-- 负责：声明实体类型、定义碰撞豁免规则（人类玩家与其他投射物），并预缓存模型与命中音效
-- ============================================================================

-- 实体类型：动画实体
ENT.Type = "anim"

-- ==== ShouldNotCollide - 判断目标是否应跳过碰撞：人类队伍玩家与其他投射物互不碰撞 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_HUMAN or ent:IsProjectile()
end

-- 预缓存投射物模型（弩箭模型）
util.PrecacheModel("models/Items/CrossbowRounds.mdl")
-- 预缓存飞行音效
util.PrecacheSound("weapons/crossbow/bolt_fly4.wav")
-- 预缓存三种金属刺入音效
util.PrecacheSound("physics/metal/sawblade_stick1.wav")
util.PrecacheSound("physics/metal/sawblade_stick2.wav")
util.PrecacheSound("physics/metal/sawblade_stick3.wav")
-- 预缓存两种命中身体音效
util.PrecacheSound("weapons/crossbow/hitbod1.wav")
util.PrecacheSound("weapons/crossbow/hitbod2.wav")
