-- ============================================================================
-- weapon_zs_chemzombie/init.lua - 化学僵尸喷吐武器（服务器端）
-- 负责：每帧驱动闲置动画；周期性（每 2 秒）对周围可见的存活人类施加
--       毒性伤害光环（近身毒雾）
-- ============================================================================
INC_SERVER()

-- 下次毒雾光环生效的时间戳
SWEP.NextAura = 0
-- ==== Think - 每帧逻辑：闲置动画补播 + 毒雾光环 ====
function SWEP:Think()
	-- 出枪动画播完后补播闲置动画
	if self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(ACT_VM_IDLE)
	end

	-- 每 2 秒对周身 40 单位内可见的存活人类施加 1 点毒性伤害
	if self.NextAura <= CurTime() then
		self.NextAura = CurTime() + 2

		-- 以所有者模型中心为光环原点
		local origin = self:GetOwner():LocalToWorld(self:GetOwner():OBBCenter())
		for _, ent in pairs(ents.FindInSphere(origin, 40)) do
			-- 只伤害可见的存活人类（视线校验）
			if ent and ent:IsValidLivingHuman() and TrueVisible(origin, ent:NearestPoint(origin)) then
				ent:PoisonDamage(1, self:GetOwner(), self)
			end
		end
	end
end
