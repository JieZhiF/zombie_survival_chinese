-- ============================================================================
-- weapon_zs_pukepus/init.lua - 呕吐僵尸武器（服务端）
-- 负责：Think 中逐发发射呕吐弹（食肉团与毒团交替），带随机弹道偏移
-- ============================================================================
INC_SERVER()

-- ==== Think - 每帧发射呕吐弹 ====
-- 有剩余呕吐弹且冷却已过时，发射一发并施加随机角度/速度偏移
function SWEP:Think()
	local pl = self:GetOwner()

	-- 有剩余呕吐弹且冷却已过，则发射一发
	if self.PukeLeft > 0 and CurTime() >= self.NextPuke then
		self.PukeLeft = self.PukeLeft - 1
		self.NextEmit = CurTime() + 0.1
		pl.LastRangedAttack = CurTime()

		-- 每 6 发出现 1 发食肉团（伤害弹），其余为毒团
		local ent = ents.Create(self.PukeLeft % 6 == 1 and "projectile_ghoulfleshpuke" or "projectile_poisonpuke")
		if ent:IsValid() then
			ent:SetPos(pl:EyePos())
			ent:SetOwner(pl)
			ent:Spawn()

			-- 给弹体施加带随机偏移的初速度（绕前向轴旋转 ±6°，绕上轴 ±22°）
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				local ang = pl:EyeAngles()
				ang:RotateAroundAxis(ang:Forward(), math.Rand(-6, 6))
				ang:RotateAroundAxis(ang:Up(), math.Rand(-22, 22))
				phys:SetVelocityInstantaneous(ang:Forward() * math.Rand(625, 750))
			end
		end
	end

	self:NextThink(CurTime())
	return true
end
