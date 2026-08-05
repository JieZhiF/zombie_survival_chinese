-- ============================================================================
-- status_revive2 - 复活状态实体（共享端）
-- 负责：通过网络变量同步复活完成时间戳，并提供"是否处于起身阶段"的判断
-- ============================================================================

-- 实体类型：动画实体
ENT.Type = "anim"
-- 母类：通用状态实体基类
ENT.Base = "status__base"

-- ==== IsRising - 判断玩家是否处于起身阶段（距复活完成时间不足 2.5 秒） ====
function ENT:IsRising()
	return self:GetReviveTime() - 2.5 <= CurTime()
end

-- ==== SetReviveTime - 网络同步设置复活完成时间戳 ====
function ENT:SetReviveTime(tim)
	self:SetDTFloat(0, tim)
end

-- ==== GetReviveTime - 读取网络同步的复活完成时间戳 ====
function ENT:GetReviveTime()
	return self:GetDTFloat(0)
end
