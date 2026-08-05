-- ============================================================================
-- projectile_shadeice/shared.lua - 寒冰投射物（共享定义）
-- 负责：定义冰弹实体的基础类型与碰撞豁免规则：不受子弹/近战/视线追踪影响，
--       飞行中不与亡灵玩家及其他投射物发生物理碰撞
-- ============================================================================
ENT.Type = "anim"

-- 免疫子弹伤害
ENT.IgnoreBullets = true
-- 免疫近战伤害
ENT.IgnoreMelee = true
-- 忽略玩家视线追踪（不可被准星瞄准选中）
ENT.IgnoreTraces = true

-- 渲染组：半透明（配合客户端着色材质显示）
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

-- ==== ShouldNotCollide - 碰撞豁免：亡灵玩家与其他投射物直接穿过 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_UNDEAD or ent:IsProjectile()
end

-- 预缓存冰弹使用的模型
util.PrecacheModel("models/props_wasteland/rockcliff01g.mdl")
