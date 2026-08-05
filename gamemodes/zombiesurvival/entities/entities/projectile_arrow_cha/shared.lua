-- ============================================================================
-- shared.lua - 混沌之箭投射物（共享）：声明实体类型与碰撞过滤
-- 负责：定义混沌之箭的碰撞规则并预缓存模型与音效资源
-- ============================================================================
-- 动画实体类型（带物理模拟的投射物）
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞过滤：玩家、其他投射物与僵尸建造物不阻挡箭矢 ====
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
