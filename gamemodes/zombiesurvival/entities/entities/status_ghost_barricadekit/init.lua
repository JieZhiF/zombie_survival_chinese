-- ============================================================================
-- init.lua - 路障工具放置虚影（服务器）：有效性刷新与武器检查
-- 负责：持续刷新放置有效性；持有路障工具时虚影存在，否则移除
-- ============================================================================
INC_SERVER()

-- ==== Think - 刷新放置有效性，武器不符时移除虚影 ====
function ENT:Think()
	-- 重算当前放置位置是否合法（地基/碰撞/距离等）
	self:RecalculateValidity()

	local owner = self:GetOwner()
	-- 仅当拥有者存活且仍手持路障工具时保留虚影
	if not (owner:IsValid() and owner:GetActiveWeapon():IsValid() and owner:GetActiveWeapon():GetClass() == "weapon_zs_barricadekit") then
		self:Remove()
	end
end
