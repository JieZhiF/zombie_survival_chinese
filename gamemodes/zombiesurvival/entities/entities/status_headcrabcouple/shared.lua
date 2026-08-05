-- ============================================================================
-- status_headcrabcouple/shared.lua - 头蟹情侣状态（共享定义）
-- 负责：通过网络变量同步伴侣实体，并根据是否有伴侣切换拥有者头蟹外观
-- ============================================================================

-- 实体类型：动画实体，基于状态基类 status__base
ENT.Type = "anim"
ENT.Base = "status__base"

-- ==== SetPartner - 设置伴侣实体：同步网络变量并更新拥有者外观 ====
function ENT:SetPartner(partner)
	-- 无伴侣时以 NULL 实体占位
	partner = partner or NULL

	-- 同步伴侣实体引用到客户端
	self:SetDTEntity(0, partner)

	-- 根据伴侣是否存在切换拥有者的头蟹外观组（1=带头蟹，0=不带）
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner:SetBodyGroup(1, partner:IsValid() and 1 or 0)
	end
end

-- ==== GetPartner - 读取伴侣实体引用 ====
function ENT:GetPartner()
	return self:GetDTEntity(0)
end
