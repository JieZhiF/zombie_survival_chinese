-- ============================================================================
-- projectile_bomb_sticky/shared.lua - 粘性炸弹投射物（共享定义）
-- 负责：定义吸附式炸弹的蓄力机制：免疫子弹、飞行中穿过玩家，
--       吸附后随时间从 0.5 蓄力至 1（满蓄力爆炸伤害最大化）
-- ============================================================================
ENT.Type = "anim"

-- 免疫子弹伤害
ENT.IgnoreBullets = true
-- 完全蓄力所需时间（秒）
ENT.ChargeTime = 3

-- 网络化属性：吸附命中的时间戳
AccessorFuncDT(ENT, "HitTime", "Float", 0)
-- 网络化属性：炸弹生成的时间戳
AccessorFuncDT(ENT, "TimeCreated", "Float", 1)

-- ==== ShouldNotCollide - 碰撞豁免：玩家与其他投射物飞行中直接穿过 ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer() or ent:IsProjectile()
end

-- ==== GetCharge - 蓄力进度：未吸附为 0，吸附后随时间线性提升至 1 ====
function ENT:GetCharge()
	if self:GetTimeCreated() == 0 then return 0 end

	return math.Clamp(0.5 + (CurTime() - self:GetTimeCreated()) / self.ChargeTime / 2, 0, 1)
end

-- 预缓存炸弹模型
util.PrecacheModel("models/combine_helicopter/helicopter_bomb01.mdl")
