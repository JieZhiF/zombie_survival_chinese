-- ============================================================================
-- weapon_zs_base/sh_think.lua - 武器母本 Think 逻辑（共享）
-- 负责：机瞄输入与网络同步、换弹完成处理、待机动画、客户端后坐力消散与镜头平滑
-- ============================================================================

-- ==== Think - 每帧更新：机瞄输入、完成换弹、播放待机动画、驱动后坐力消散 ====
function SWEP:Think()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	-- [网络同步] 客户端检测 DT 布尔翻转并补记时间戳；首次同步仅建立基线，不视为翻转
	local iron = self:GetIronsights()
	if iron ~= self.m_bLastIronNet then
		if self.m_bLastIronNet ~= nil then
			self.fIronTime = CurTime()
		end
		self.m_bLastIronNet = iron
	end

	-- [瞄准输入] 切换模式按右键沿翻转；长按模式松开即退出
	if self:IsToggleADS() then
		if owner:KeyPressed(IN_ATTACK2) and self.IronEnable ~= false and not owner:IsHolding() and self:GetReloadFinish() == 0 then
			self:SetIronsights(not iron)
		end
	elseif iron and not owner:KeyDown(IN_ATTACK2) then
		self:SetIronsights(false)
	end

	-- [卡墙] 幽灵探身时强制收镜，避免视角模型与探身动作叠加错位
	if self:GetIronsights() and owner:GetBarricadeGhosting() then
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
	end

	-- [双轨分离] 后坐力 Think 提升为共享域：热度消散/连射计数/弹道偏移衰减
	-- 需要服务端与客户端预测保持一致；镜头平滑等纯表现逻辑在函数内部按 realm 分支
	self:ThinkRecoil()
end

-- ==== ThinkRecoil - 热度消散、连射计数重置、[实际轨]弹道偏移指数衰减与镜头平滑回正 ====
function SWEP:ThinkRecoil()
	local ct = CurTime()
	local ft = FrameTime()
	if ft == 0 then return end
	local rft = CLIENT and RealFrameTime() or ft

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

	-- 2. [实际轨] 后坐力累积指数衰减（ARC9式 ru - ft*ru*10）：共享域执行保证双端一致
	local bu = self.RecoilAccumUp or 0
	local bs = self.RecoilAccumSide or 0
	if bu ~= 0 or bs ~= 0 then
		bu = bu - ft * bu * 10
		bs = bs - ft * bs * 10
		self.RecoilAccumUp = math.abs(bu) < 0.001 and 0 or bu
		self.RecoilAccumSide = math.abs(bs) < 0.001 and 0 or bs
	end

	-- 3. 连射计数重置 (停火超过自动回正时间后重置)
	local autoTime = self.RecoilAutoControlTime or 0.1
	if (ct - self.last_shot_time) > autoTime then
		self.ShotCount = 0
	end

	-- 4. 客户端视觉平滑 (快速回位)
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
