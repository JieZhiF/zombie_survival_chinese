-- ============================================================================
-- status_ghost_base/init.lua - 幽灵放置预览状态（服务器）
-- 负责：逐帧校验放置有效性；当拥有者不再持有对应的幽灵武器时移除自身
-- ============================================================================
INC_SERVER()

-- ==== Think - 每帧校验放置有效性，并检查幽灵武器是否仍被持有 ====
function ENT:Think()
	-- 重新计算放置点有效性（供客户端读取）
	self:RecalculateValidity()

	-- 拥有者无效、无当前武器或当前武器不是幽灵武器时，移除预览
	local owner = self:GetOwner()
	if not (owner:IsValid() and owner:GetActiveWeapon():IsValid() and owner:GetActiveWeapon():GetClass() == self.GhostWeapon) then
		self:Remove()
	end

	-- 每帧持续运行
	self:NextThink(CurTime())
	return true
end
