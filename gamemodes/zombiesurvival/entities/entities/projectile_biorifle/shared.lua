-- ============================================================================
-- projectile_biorifle/shared.lua - 生物步枪投射物（共享）
-- 负责：定义弹体基础属性（不阻挡子弹、与人类的碰撞规则），
--       并记录命中时间与生成时间供飞行/爆炸逻辑使用
-- ============================================================================
-- 实体类型为动画实体
ENT.Type = "anim"

-- 该实体不阻挡子弹（子弹可穿过）
ENT.IgnoreBullets = true

-- 命中时间（命中目标时记录，用于结算）
AccessorFuncDT(ENT, "HitTime", "Float", 0)
-- 生成时间（CurTime 时间戳，用于计算飞行寿命）
AccessorFuncDT(ENT, "TimeCreated", "Float", 1)

-- ==== ShouldNotCollide - 碰撞豁免：与人类玩家不发生碰撞（误伤保护） ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() and ent:Team() == TEAM_HUMAN
end

-- 预缓存炸弹模型，避免运行时加载卡顿
util.PrecacheModel("models/combine_helicopter/helicopter_bomb01.mdl")
