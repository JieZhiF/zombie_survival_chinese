-- ============================================================================
-- projectile_zsgrenade/shared.lua - 手雷投射物实体（共享端）
-- 负责：声明手雷寿命、碰撞过滤规则，并预缓存金属碰撞音效
-- ============================================================================

ENT.Type = "anim"

-- 手雷从投出到爆炸的存活时间（秒）
ENT.LifeTime = 2.5

-- 第 0 波期间不对手雷伤害实体/障碍物（保护开局建筑）
ENT.NoPropDamageDuringWave0 = true

-- ==== ShouldNotCollide - 碰撞过滤 ====
-- 手雷飞行中与玩家不碰撞（避免近距离弹开）
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer()
end

-- 预缓存金属落地碰撞音效（避免飞行途中首次落地卡顿）
util.PrecacheSound("physics/metal/metal_grenade_impact_hard1.wav")
util.PrecacheSound("physics/metal/metal_grenade_impact_hard2.wav")
util.PrecacheSound("physics/metal/metal_grenade_impact_hard3.wav")
