-- ============================================================================
-- shared.lua - 符石传送状态（共享）
-- 负责：记录传送的起点/终点符石与时间信息，供服务端/客户端同步使用
-- ============================================================================
-- 基于 anim 实体类型，继承状态类基座 status__base
ENT.Type = "anim"
ENT.Base = "status__base"

-- ==== GetTimeRemaining - 获取剩余传送时间 ====
-- 返回结束时间减去当前时间，最小为 0
function ENT:GetTimeRemaining()
	return math.max(0, self:GetEndTime() - CurTime())
end

-- ==== RefreshMaxTime - 刷新最大持续时间 ====
-- 最大时间取历史最大值与当前实际持续时间的较大者（状态叠加时保持进度条不倒退）
function ENT:RefreshMaxTime()
	self:SetMaxTime(math.max(self:GetMaxTime(), self:GetEndTime() - self:GetStartTime()))
end

-- ==== SetMaxTime - 写入最大持续时间（DT 槽 2）====
function ENT:SetMaxTime(time)
	self:SetDTFloat(2, time)
end

-- ==== GetMaxTime - 读取最大持续时间（DT 槽 2）====
function ENT:GetMaxTime()
	return self:GetDTFloat(2)
end

-- ==== SetEndTime - 写入结束时间（DT 槽 0）并刷新最大持续时间 ====
function ENT:SetEndTime(time)
	self:SetDTFloat(0, time)
	self:RefreshMaxTime()
end

-- ==== GetEndTime - 读取结束时间（DT 槽 0）====
function ENT:GetEndTime()
	return self:GetDTFloat(0)
end

-- ==== GetStartTime - 读取开始时间（DT 槽 1）====
function ENT:GetStartTime()
	return self:GetDTFloat(1)
end

-- ==== SetStartTime - 写入开始时间（DT 槽 1）并刷新最大持续时间 ====
function ENT:SetStartTime(time)
	self:SetDTFloat(1, time)
	self:RefreshMaxTime()
end

-- ==== GetTargetSigil - 查询传送目标符石 ====
-- 通过父实体（主人）查询目的地符石；腐化传送状态使用另一套目的地规则
function ENT:GetTargetSigil()
	local owner = self:GetParent()
	if owner:IsValid() then
		return owner:SigilTeleportDestination(self:GetFromSigil():IsValid() and self:GetFromSigil():IsWeapon(), self:GetClass() == "status_corruptedteleport")
	end

	return NULL
end

-- ==== SetFromSigil - 记录来源符石（DT 实体槽 1）====
function ENT:SetFromSigil(ent)
	self:SetDTEntity(1, ent)
end

-- ==== GetFromSigil - 读取来源符石（DT 实体槽 1）====
function ENT:GetFromSigil()
	return self:GetDTEntity(1)
end
