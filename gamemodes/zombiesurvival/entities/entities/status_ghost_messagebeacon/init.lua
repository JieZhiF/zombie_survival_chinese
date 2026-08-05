-- ============================================================================
-- status_ghost_messagebeacon - 讯息信标放置幽灵预览状态实体（服务端）
-- 负责：持续刷新放置合法性，持有者不再手持信标武器时移除幽灵
-- ============================================================================
INC_SERVER()

-- ==== Think - 每帧刷新放置合法性；持有者切换到其他武器时移除幽灵预览 ====
function ENT:Think()
	self:RecalculateValidity()

	local owner = self:GetOwner()
	if not (owner:IsValid() and owner:GetActiveWeapon():IsValid() and owner:GetActiveWeapon():GetClass() == "weapon_zs_messagebeacon") then
		self:Remove()
	end
end
