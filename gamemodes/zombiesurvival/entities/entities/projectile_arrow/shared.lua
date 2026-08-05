-- ============================================================================
-- projectile_arrow/shared.lua - 弓箭投射物（共享）
-- 负责：声明投射物类型与碰撞过滤（不碰撞玩家/其他投射物/僵尸建造物），
--       预缓存箭矢模型与命中/飞行音效
-- ============================================================================
-- 动画实体类型（由服务器驱动飞行与碰撞）
ENT.Type = "anim"

-- ==== ShouldNotCollide - 碰撞过滤：玩家、其他投射物与僵尸建造物直接穿过 ====
function ENT:ShouldNotCollide(ent)
	-- 避免与玩家（友军）、其他投射物及僵尸建造物发生碰撞
	return ent:IsPlayer() or ent:IsProjectile() or ent.ZombieConstruction
end

-- 预缓存箭矢模型与飞行/命中音效，避免运行时加载卡顿
util.PrecacheModel("models/Items/CrossbowRounds.mdl")
util.PrecacheSound("weapons/crossbow/bolt_fly4.wav")
util.PrecacheSound("physics/metal/sawblade_stick1.wav")
util.PrecacheSound("physics/metal/sawblade_stick2.wav")
util.PrecacheSound("physics/metal/sawblade_stick3.wav")
util.PrecacheSound("weapons/crossbow/hitbod1.wav")
util.PrecacheSound("weapons/crossbow/hitbod2.wav")
