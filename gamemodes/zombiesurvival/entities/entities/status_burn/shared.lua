-- ============================================================================
-- status_burn/shared.lua - 燃烧状态（共享）
-- 负责：燃烧负面状态的实体定义——通过数据表同步燃烧伤害值（上限 50）
--       与起始时间；服务器 Think 定期造成灼烧伤害并逐次削减伤害值
-- ============================================================================

-- 动画实体类型（可附着在拥有者身上跟随移动）
ENT.Type = "anim"
-- 继承通用状态实体基类，复用生命周期管理
ENT.Base = "status__base"

-- 瞬时状态标记：玩家死亡/状态重置时一并清除
ENT.Ephemeral = true

-- ==== Initialize - 初始化：关闭阴影并记录燃烧起始时间 ====
function ENT:Initialize()
	-- 燃烧状态实体不投射阴影
	self:DrawShadow(false)
	-- 首次初始化时记录起始时间（DT Float 槽 1，只写入一次）
	if self:GetDTFloat(1) == 0 then
		self:SetDTFloat(1, CurTime())
	end
end

-- ==== AddDamage - 增加/削减当前燃烧伤害值（正数叠加，负数衰减） ====
function ENT:AddDamage(damage)
	self:SetDamage(self:GetDamage() + damage)
end

-- ==== SetDamage - 设置燃烧伤害值（钳制在 50 以内，DT Float 槽 0） ====
function ENT:SetDamage(damage)
	self:SetDTFloat(0, math.min(50, damage))
end

-- ==== GetDamage - 获取当前燃烧伤害值 ====
function ENT:GetDamage()
	return self:GetDTFloat(0)
end
