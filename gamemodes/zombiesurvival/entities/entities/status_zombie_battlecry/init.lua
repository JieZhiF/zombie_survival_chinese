-- ============================================================================
-- status_zombie_battlecry/init.lua - 僵尸战吼状态（服务器）
-- 负责：战吼状态每 0.1 秒校验一次存活条件——拥有者受到麻痹
--       （shockdebuff）或战吼时限（DieTime）已到则移除自身
-- ============================================================================
INC_SERVER()

-- ==== Think - 存活校验：被麻痹或超时即结束战吼 ====
function ENT:Think()
	local owner = self:GetOwner()

	-- 拥有者处于麻痹状态时战吼立即中断
	if owner:GetStatus("shockdebuff") then
		self:Remove()
		return
	end

	-- 战吼持续时间（DieTime 由施放方设定）已到则结束
	if self.DieTime <= CurTime() then
		self:Remove()
	end

	-- 每 0.1 秒校验一次，避免逐帧开销
	self:NextThink(CurTime() + 0.1)
	return true
end
