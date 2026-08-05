-- ============================================================================
-- status_headcrabcouple/init.lua - 头蟹情侣状态（服务器）
-- 负责：在玩家身上登记情侣状态引用；移除时恢复无头蟹外观并清除引用
-- ============================================================================
INC_SERVER()

-- ==== PlayerSet - 附加到玩家：登记情侣状态引用（供情侣机制查询） ====
function ENT:PlayerSet(pPlayer, bExists)
	pPlayer.m_Couple = self
end

-- ==== Remove - 移除状态：恢复拥有者头蟹外观并清除情侣引用 ====
function ENT:Remove()
	local owner = self:GetOwner()
	if owner:IsValid() and owner.m_Couple == self then
		-- 恢复无头蟹外观组
		owner:SetBodyGroup(1, 0)
		owner.m_Couple = nil
	end
end

-- ==== Think - 无持续逻辑（占位实现） ====
function ENT:Think()
end
