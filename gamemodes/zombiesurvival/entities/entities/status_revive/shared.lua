-- ============================================================================
-- shared.lua - 复活状态（共享）：声明实体类型与复活计时接口
-- 负责：提供复活完成时间点的读写，以及起身动画阶段的判断
-- ============================================================================
-- 动画实体类型
ENT.Type = "anim"
-- 基类为状态实体基类
ENT.Base = "status__base"

-- ==== IsRising - 是否已进入起身动画阶段（复活完成前最后 2.5 秒） ====
function ENT:IsRising()
	return self:GetReviveTime() - 2.5 <= CurTime()
end

-- ==== SetReviveTime - 设置复活完成时间点 ====
function ENT:SetReviveTime(tim)
	self:SetDTFloat(0, tim)
end

-- ==== GetReviveTime - 读取复活完成时间点 ====
function ENT:GetReviveTime()
	return self:GetDTFloat(0)
end
