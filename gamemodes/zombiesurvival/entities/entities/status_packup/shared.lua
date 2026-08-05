-- ============================================================================
-- status_packup/shared.lua - 收包状态（共享部分）
-- 负责：定义收包状态的网络同步字段（开始/结束/最大时间、目标物件实体、
--       是否非所有者收包），供服务器端执行收包流程、客户端显示进度
-- ============================================================================

-- 实体类型：动画实体，继承状态基类
ENT.Type = "anim"
ENT.Base = "status__base"

-- 非所有者收包时，同一物件的最大并发收包数量上限
ENT.PackUpOverride = 4

-- ==== GetTimeRemaining - 获取剩余收包时间 ====
function ENT:GetTimeRemaining()
	return math.max(0, self:GetEndTime() - CurTime())
end

-- ==== RefreshMaxTime - 刷新最大持续时间 ====
-- 保证最大时间至少覆盖已过去的时间段（供客户端绘制进度条）
function ENT:RefreshMaxTime()
	self:SetMaxTime(math.max(self:GetMaxTime(), self:GetEndTime() - self:GetStartTime()))
end

-- ==== SetMaxTime - 写入最大持续时间（DT 浮点槽 2） ====
function ENT:SetMaxTime(time)
	self:SetDTFloat(2, time)
end

-- ==== GetMaxTime - 读取最大持续时间 ====
function ENT:GetMaxTime()
	return self:GetDTFloat(2)
end

-- ==== SetEndTime - 写入收包结束时间（DT 浮点槽 0） ====
function ENT:SetEndTime(time)
	self:SetDTFloat(0, time)
	self:RefreshMaxTime()
end

-- ==== GetEndTime - 读取收包结束时间 ====
function ENT:GetEndTime()
	return self:GetDTFloat(0)
end

-- ==== GetStartTime - 读取收包开始时间（DT 浮点槽 1） ====
function ENT:GetStartTime()
	return self:GetDTFloat(1)
end

-- ==== SetStartTime - 写入收包开始时间 ====
function ENT:SetStartTime(time)
	self:SetDTFloat(1, time)
	self:RefreshMaxTime()
end

-- ==== SetPackUpEntity - 记录被收包的物件实体（DT 实体槽 0） ====
function ENT:SetPackUpEntity(ent)
	self:SetDTEntity(0, ent)
end

-- ==== GetPackUpEntity - 读取被收包的物件实体 ====
function ENT:GetPackUpEntity()
	return self:GetDTEntity(0)
end

-- ==== SetNotOwner - 标记是否由非物件所有者进行收包（DT 布尔槽 0） ====
function ENT:SetNotOwner(notowner)
	self:SetDTBool(0, notowner)
end

-- ==== GetNotOwner - 读取非所有者收包标记 ====
function ENT:GetNotOwner()
	return self:GetDTBool(0)
end
