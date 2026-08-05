-- ============================================================================
-- shared.lua - 溺水状态（共享）：声明实体类型与溺水进度接口
-- 负责：提供溺水进度（0~1）随时间增减的计算，以及氧气罐饰品的加成
-- ============================================================================
-- 动画实体类型
ENT.Type = "anim"
-- 基类为状态实体基类
ENT.Base = "status__base"

-- ==== SetDrown - 记录当前时刻并写入溺水进度 ====
function ENT:SetDrown(drownamount)
	self:SetDTFloat(0, CurTime())
	self:SetDTFloat(1, drownamount)
end

-- ==== SetUnderwater - 切换水下/岸上状态并刷新进度计算基准 ====
function ENT:SetUnderwater(underwater)
	-- 切换前先固化当前进度，作为新状态下的计算起点
	self:SetDrown(self:GetDrown())

	self:SetDTBool(0, underwater)
end

-- ==== GetUnderwater - 读取是否处于水下 ====
function ENT:GetUnderwater()
	return self:GetDTBool(0)
end
-- 别名：IsUnderwater（语义化命名）
ENT.IsUnderwater = ENT.GetUnderwater

-- ==== GetDrown - 计算当前溺水进度（0 无 ~ 1 淹死） ====
function ENT:GetDrown()
	if self:IsUnderwater() then
		-- 水下：按溺水耗时占满屏时间的比例累积进度
		return math.Clamp(self:GetDTFloat(1) + (CurTime() - self:GetDTFloat(0)) / self:GetDrownTime(), 0, 1)
	else
		-- 岸上：按恢复耗时占恢复时间的比例回落进度
		return math.Clamp(self:GetDTFloat(1) - (CurTime() - self:GetDTFloat(0)) / self:GetRecoverTime(), 0, 1)
	end
end

-- ==== GetDrownTime - 溺水进度充满所需秒数（氧气罐饰品大幅延长） ====
function ENT:GetDrownTime()
	local owner = self:GetOwner()
	if owner:IsValid() and owner:HasTrinket("oxygentank") then
		return 300
	end

	return 30
end

-- ==== GetRecoverTime - 溺水进度清零所需秒数（氧气罐饰品延长恢复） ====
function ENT:GetRecoverTime()
	local owner = self:GetOwner()
	if owner:IsValid() and owner:HasTrinket("oxygentank") then
		return 20
	end

	return 10
end

-- ==== IsDrowning - 是否正处溺水掉血状态（进度满且在水下） ====
function ENT:IsDrowning()
	return self:GetDrown() == 1 and self:GetUnderwater()
end
