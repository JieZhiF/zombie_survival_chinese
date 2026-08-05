-- ============================================================================
-- projectile_flakbomb/shared.lua - 高射炮弹（母弹）投射物（共享定义）
-- 负责：声明投射物类型、不伤人类的碰撞豁免规则，并预缓存炸弹模型
-- ============================================================================

-- 实体类型：动画物理投射物
ENT.Type = "anim"

-- ==== ShouldNotCollide - 不与人类玩家碰撞（对亡灵阵营造成伤害） ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_HUMAN
end

-- 预缓存直升机炸弹模型（母弹外观）
util.PrecacheModel("models/combine_helicopter/helicopter_bomb01.mdl")
