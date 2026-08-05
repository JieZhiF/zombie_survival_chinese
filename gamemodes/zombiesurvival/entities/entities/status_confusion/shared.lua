-- ============================================================================
-- shared.lua - 混乱状态（共享）：声明状态类型与起止时间/强度存取
-- 负责：提供混乱状态的时间窗口 DT 数据与强度包络（渐入渐出）计算
-- ============================================================================
-- 动画实体类型
ENT.Type = "anim"
-- 继承状态基类（附带玩家状态管理框架）
ENT.Base = "status__base"

-- 短暂状态：只存在于生效期间，不持久化保存
ENT.Ephemeral = true

-- ==== SetEndTime - 写入结束时间（DT 同步到客户端） ====
function ENT:SetEndTime(time)
	self:SetDTFloat(0, time)
end

-- ==== GetEndTime - 读取结束时间 ====
function ENT:GetEndTime()
	return self:GetDTFloat(0)
end

-- ==== SetStartTime - 写入开始时间（DT 同步到客户端） ====
function ENT:SetStartTime(time)
	self:SetDTFloat(1, time)
end

-- ==== GetStartTime - 读取开始时间 ====
function ENT:GetStartTime()
	return self:GetDTFloat(1)
end

-- ==== GetPower - 强度包络：开始 1 秒内渐强到满，临近结束时渐弱到 0 ====
function ENT:GetPower()
	local curtime = CurTime()
	local power = math.min(1, curtime - self:GetStartTime())
	if power == 1 then
		power = math.min(1, self:GetEndTime() - curtime)
	end

	return power
end
