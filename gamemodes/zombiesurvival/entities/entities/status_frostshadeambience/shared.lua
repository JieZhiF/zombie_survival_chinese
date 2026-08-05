-- ============================================================================
-- status_frostshadeambience/shared.lua - 霜影氛围实体（共享）
-- 负责：声明以 status_ambience_base 为基类的氛围挂件：拥有者为
--       "Frost Shade" 职业时保留；并提供最近受击时间/伤害的
--       DT 读写接口，供冰霜反击技能逻辑使用
-- ============================================================================

-- 实体类型：动画实体（生命周期由基类统一管理）
ENT.Type = "anim"

-- 基类：氛围实体基类，负责按职业名匹配拥有者并设置模型
ENT.Base = "status_ambience_base"
-- 匹配的僵尸职业名：拥有者为 "Frost Shade" 时保留本实体
ENT.AmbienceClassNames = {"Frost Shade"}

-- ==== SetLastDamaged - 写入最近一次受到伤害的时间（DT 浮点 0 号位）====
function ENT:SetLastDamaged(time)
	self:SetDTFloat(0, time)
end

-- ==== GetLastDamaged - 读取最近一次受到伤害的时间 ====
function ENT:GetLastDamaged()
	return self:GetDTFloat(0)
end

-- ==== SetLastDamage - 写入最近一次受到的伤害值（DT 浮点 1 号位）====
function ENT:SetLastDamage(damage)
	self:SetDTFloat(1, damage)
end

-- ==== GetLastDamage - 读取最近一次受到的伤害值 ====
function ENT:GetLastDamage()
	return self:GetDTFloat(1)
end

