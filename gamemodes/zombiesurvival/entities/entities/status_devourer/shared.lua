-- ============================================================================
-- status_devourer/shared.lua - 吞噬状态（共享）
-- 负责：以 DT 网络变量保存状态剩余伤害量与拉拽者（Puller）实体引用，
--       供服务器端 Think 每帧拉拽结算使用
-- ============================================================================
-- 实体类型为动画实体，继承 status__base 状态基类
ENT.Type = "anim"
ENT.Base = "status__base"

-- ==== SetDamage - 设置剩余伤害量：上限钳制为 15（决定拉拽持续次数） ====
function ENT:SetDamage(damage)
	self:SetDTFloat(0, math.min(15, damage))
end

-- ==== GetDamage - 读取剩余伤害量 ====
function ENT:GetDamage()
	return self:GetDTFloat(0)
end

-- ==== SetPuller - 设置拉拽者（施放技能者）实体 ====
function ENT:SetPuller(puller)
	self:SetDTEntity(0, puller)
end

-- ==== GetPuller - 读取拉拽者实体 ====
function ENT:GetPuller()
	return self:GetDTEntity(0)
end
