-- ============================================================================
-- projectile_arrow_inq/shared.lua - 审判者之箭投射物（共享部分）
-- 负责：定义审判者弓（weapon_zs_inqbow）射出的箭矢投射物，
--       设置碰撞过滤规则（穿透玩家/其他投射物/僵尸建筑），
--       并预缓存模型与飞行音效资源
-- ============================================================================

-- 实体类型：动画实体（投射物）
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞过滤规则 ====
-- 玩家、其他投射物、僵尸建造物不参与碰撞（箭矢直接穿透）
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() or ent:IsProjectile() or ent.ZombieConstruction
end

-- 预缓存箭矢模型与飞行/命中音效，避免运行时卡顿
util.PrecacheModel("models/Items/CrossbowRounds.mdl")
util.PrecacheSound("weapons/crossbow/bolt_fly4.wav")
util.PrecacheSound("physics/metal/sawblade_stick1.wav")
util.PrecacheSound("physics/metal/sawblade_stick2.wav")
util.PrecacheSound("physics/metal/sawblade_stick3.wav")
util.PrecacheSound("weapons/crossbow/hitbod1.wav")
util.PrecacheSound("weapons/crossbow/hitbod2.wav")
