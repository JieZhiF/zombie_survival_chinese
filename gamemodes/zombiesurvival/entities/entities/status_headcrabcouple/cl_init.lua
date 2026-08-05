-- ============================================================================
-- status_headcrabcouple/cl_init.lua - 头蟹情侣状态（客户端）
-- 负责：禁用状态实体阴影并登记情侣引用；移除时清除引用
-- ============================================================================
INC_CLIENT()

-- ==== Initialize - 初始化：关闭阴影并登记情侣状态引用 ====
function ENT:Initialize()
	-- 状态实体不投射阴影（不可见的挂载实体）
	self:DrawShadow(false)

	self:GetOwner().m_Couple = self
end

-- ==== OnRemove - 移除时清除玩家身上的情侣引用 ====
function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner:IsValid() and owner.m_Couple == self then
		owner.m_Couple = nil
	end
end
