-- ============================================================================
-- status_feigndeath/shared.lua - 装死状态（共享定义）
-- 负责：冻结携带者移动速度；通过网络变量同步装死状态、起身倒计时与倒地方向
-- ============================================================================

-- 实体类型：动画实体，基于状态基类 status__base
ENT.Type = "anim"
ENT.Base = "status__base"

-- ==== Move - 移动修正：装死期间将移动速度钳制为 0 ====
function ENT:Move(pl, move)
	-- 只影响本状态的携带者
	if pl ~= self:GetOwner() then return end

	-- 同时钳制服务器与客户端预测速度，保证完全无法移动
	move:SetMaxSpeed(0)
	move:SetMaxClientSpeed(0)
end

-- ==== SetState - 设置装死阶段（0=装死中，1=可起身） ====
function ENT:SetState(state)
	self:SetDTInt(0, state)
end

-- ==== GetState - 读取装死阶段 ====
function ENT:GetState()
	return self:GetDTInt(0)
end

-- ==== SetStateEndTime - 设置阶段结束时间戳 ====
function ENT:SetStateEndTime(time)
	self:SetDTFloat(0, time)
end

-- ==== GetStateEndTime - 读取阶段结束时间戳 ====
function ENT:GetStateEndTime()
	return self:GetDTFloat(0)
end

-- ==== SetDirection - 设置倒地朝向（DIR_FORWARD/RIGHT/BACK/LEFT） ====
function ENT:SetDirection(m)
	self:SetDTInt(1, m)
end

-- ==== GetDirection - 读取倒地朝向 ====
function ENT:GetDirection()
	return self:GetDTInt(1)
end
