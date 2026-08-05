-- ============================================================================
-- weapon_zs_baseproj/cl_init.lua - 投射物武器基础模板（客户端）
-- 负责：客户端开火时的武器动画与后坐力视角震动（预测）
-- ============================================================================

INC_CLIENT()

-- 第一人称视角设置：不翻转；武器类型标记为投射物
SWEP.ViewModelFlip = false
SWEP.WeaponType = "projectile"
-- ==== ShootBullets - 客户端开火表现：播放动画并施加后坐力视角震动 ====
function SWEP:ShootBullets(damage, numshots, cone)
	local owner = self:GetOwner()
	self:SendWeaponAnimation()
	owner:DoAttackEvent()

	-- 后坐力视角震动（轻微随机晃动）
	if self.Recoil > 0 then
		local r = math.Rand(0.8, 1)
		owner:ViewPunch(Angle(r * -self.Recoil, 0, (1 - r) * (math.random(2) == 1 and -1 or 1) * self.Recoil))
	end
end
