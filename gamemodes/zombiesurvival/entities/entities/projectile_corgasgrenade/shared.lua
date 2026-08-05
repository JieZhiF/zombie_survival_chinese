-- ============================================================================
-- projectile_corgasgrenade/shared.lua - 腐蚀毒气手雷（共享）
-- 负责：声明 anim 类型投射物；碰撞时释放腐蚀毒气云（伤害半径 75 单位），
--       玩家不阻挡手雷飞行；毒气排放状态通过 DT 同步到客户端
-- ============================================================================
ENT.Type = "anim"

-- 毒气云伤害半径（单位）
ENT.Radius = 75

-- ==== ShouldNotCollide - 碰撞豁免：玩家不阻挡手雷（穿人飞行） ====
function ENT:ShouldNotCollide(ent)
	return ent:IsPlayer()
end

-- ==== SetGasEmit - 设置毒气排放状态（DT 同步） ====
function ENT:SetGasEmit(emit)
	self:SetDTBool(0, emit)
end

-- ==== GetGasEmit - 读取毒气排放状态 ====
function ENT:GetGasEmit()
	return self:GetDTBool(0)
end
