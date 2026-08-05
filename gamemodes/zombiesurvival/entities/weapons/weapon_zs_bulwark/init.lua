-- ============================================================================
-- weapon_zs_bulwark/init.lua - 堡垒机炮（服务器端入口）
-- 负责：服务器端每帧检查预转/蓄能状态，并在开火后恢复待机动画
-- ============================================================================

INC_SERVER()

-- ==== Think - 服务器端每帧逻辑 ====
function SWEP:Think()
	-- 更新预转/蓄能状态（判定按键、管理旋转声）
	self:CheckSpool()

	-- 开火动画结束后恢复待机动画
	if self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
end
