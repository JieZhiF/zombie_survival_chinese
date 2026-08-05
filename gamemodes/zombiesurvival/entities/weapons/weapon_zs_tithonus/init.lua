-- ============================================================================
-- weapon_zs_tithonus/init.lua - 泰坦投射器（服务端）
-- 负责：定义投射物实体与速度，处理充能检查与换弹/待机动画流转
-- ============================================================================

INC_SERVER()

-- 发射的投射物实体类（泰坦弹丸）
SWEP.Primary.Projectile = "projectile_tithonus"
-- 弹丸初始飞行速度
SWEP.Primary.ProjVelocity = 1100

-- ==== Think - 每帧逻辑 ====
function SWEP:Think()
	-- 检查充能状态（蓄力攻击系统）
	self:CheckCharge()

	-- 换弹进行中：到达完成时刻则结束换弹
	if self:GetReloadFinish() > 0 then
		if CurTime() >= self:GetReloadFinish() then
			self:FinishReload()
		end
	elseif self.IdleAnimation and self.IdleAnimation <= CurTime() then
		-- 非换弹状态：出枪/开火动画结束后播放待机动画
		self.IdleAnimation = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end
end
