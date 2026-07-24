-- sh_think.lua

function SWEP:Think()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if self:GetIronsights() and not owner:KeyDown(IN_ATTACK2) then
		self:SetIronsights(false)
	end

	if self:GetReloadFinish() > 0 then
		if CurTime() >= self:GetReloadFinish() then
			self:FinishReload()
		end
	elseif self.IdleAnimation and self.IdleAnimation <= CurTime() then
		self.IdleAnimation = nil
		self:SendWeaponAnim(self.IdleActivity)
	end

	if CLIENT then
		self.offset = Lerp(RealFrameTime() * 10, self.offset or 0, 0)
		self:ThinkRecoil()
	end
end

function SWEP:ThinkRecoil()
	local ct = CurTime()
	local ft = FrameTime()
	local rft = RealFrameTime()
	if ft == 0 then return end

	local last_shot = self.last_shot_time or 0
	local recoil_amount = self.RecoilAmount or 0

	-- 1. 热度消散 (停火后逐渐冷却)
	local resetTime = self.RecoilResetTime or 0.12
	if ct > (last_shot + resetTime) then
		if recoil_amount > 0 then
			local decay = ft * (self.RecoilDissipationRate or 10) * 1.5
			self.RecoilAmount = math.max(recoil_amount - decay, 0)
		end
	end

	-- 2. 换弹回正结束检测
	if self.IsReloadingRecoil and self.Recoil_RecoverPool then
		if math.abs(self.Recoil_RecoverPool.p) < 0.001 then
			self.IsReloadingRecoil = false
		end
	end

	-- 3. 连射计数重置 (停火超过自动回正时间后重置)
	local autoTime = self.RecoilAutoControlTime or 0.1
	if (ct - self.last_shot_time) > autoTime then
		self.ShotCount = 0
	end

	-- 4. 客户端视觉平滑 (COD风格: 快速回位)
	if CLIENT then
		self.CamRecoilCurrent = self.CamRecoilCurrent or Angle(0, 0, 0)
		self.CamRecoilTarget = self.CamRecoilTarget or Angle(0, 0, 0)

		local lerpSpeed = self.CamRecoilLerpSpeed or 22

		-- 当前值追赶目标值 (射击时瞬间弹跳)
		self.CamRecoilCurrent = LerpAngle(rft * lerpSpeed * 1.5, self.CamRecoilCurrent, self.CamRecoilTarget)

		-- 目标值快速归零 (弹跳后迅速回稳)
		self.CamRecoilTarget = LerpAngle(rft * 15, self.CamRecoilTarget, Angle(0, 0, 0))

		-- 镜头Roll回正
		self.CamRecoilRollVal = math.Approach(self.CamRecoilRollVal or 0, 0, rft * 60)

		-- 清理微小残留
		if self.CamRecoilCurrent and math.abs(self.CamRecoilCurrent.p) < 0.0001 and math.abs(self.CamRecoilCurrent.y) < 0.0001 then
			self.CamRecoilCurrent = Angle(0, 0, 0)
		end
		if self.CamRecoilTarget and math.abs(self.CamRecoilTarget.p) < 0.0001 and math.abs(self.CamRecoilTarget.y) < 0.0001 then
			self.CamRecoilTarget = Angle(0, 0, 0)
		end
	end
end
