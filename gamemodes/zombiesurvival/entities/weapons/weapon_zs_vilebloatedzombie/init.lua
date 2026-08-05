-- ============================================================================
-- init.lua - 污秽肿胀僵尸武器服务端逻辑
-- 负责：Think 每帧驱动毒液喷射——PukeLeft 剩余次数内每 0.1 秒发射一发
--       毒肉投射物（poisonflesh），带小幅随机散布
-- ============================================================================
INC_SERVER()

-- ==== Think - 每帧驱动呕吐毒液喷射 ====
function SWEP:Think()
	-- 先执行父类 Think
	self.BaseClass.Think(self)

	local pl = self:GetOwner()

	-- 喷射状态激活且到达下次喷射时刻：发射一发毒肉投射物
	if self.PukeLeft > 0 and CurTime() >= self.NextPuke then
		self.PukeLeft = self.PukeLeft - 1
		self.NextPuke = CurTime() + 0.1
		pl.LastRangedAttack = CurTime()

		-- 在玩家眼部位置生成毒肉投射物
		local ent = ents.Create("projectile_poisonflesh")
		if ent:IsValid() then
			ent:SetPos(pl:EyePos())
			ent:SetOwner(pl)
			ent:Spawn()

			-- 朝视线方向发射，上下/左右各加 ±10 度随机散布
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				local ang = pl:EyeAngles()
				ang:RotateAroundAxis(ang:Forward(), math.Rand(-10, 10))
				ang:RotateAroundAxis(ang:Up(), math.Rand(-10, 10))
				phys:SetVelocityInstantaneous(ang:Forward() * 400)
			end
		end
	end

	-- 持续调度下一帧 Think
	self:NextThink(CurTime())
	return true
end
