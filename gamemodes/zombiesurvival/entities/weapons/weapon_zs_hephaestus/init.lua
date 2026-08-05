-- ============================================================================
-- init.lua - 赫菲斯托斯（服务器端）
-- 负责：每帧处理蓄能状态与闲置动画切换
-- ============================================================================
INC_SERVER()

-- ==== Think - 每帧处理蓄能充放电与闲置动画 ====
function SWEP:Think()
	self:CheckCharge()

	-- 闲置动画计时结束则播放闲置姿势
	if self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
end
