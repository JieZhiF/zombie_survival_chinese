-- ============================================================================
-- weapon_zs_base/sh_recoil.lua - 武器母本后坐力系统（共享）
-- 负责：按状态计算后坐力倍率、开火后坐力累积/偏移与客户端镜头抖动
-- ============================================================================

-- ==== GetRecoilModifier - 按机瞄/蹲下/空中/移动状态计算后坐力倍率 ====
function SWEP:GetRecoilModifier()
	local owner = self:GetOwner()
	if not IsValid(owner) then return 1 end
	
	local mod = 1
	if self:GetIronsights() then mod = mod * (self.RecoilMultSights or 0.5) end
	if owner:Crouching() then mod = mod * (self.RecoilMultCrouch or 0.75) end
	if not owner:IsOnGround() then mod = mod * (self.RecoilMultMidAir or 2.0) end
	if owner:GetVelocity():Length2D() > 70 then mod = mod * (self.RecoilMultMove or 1.3) end
	
	return mod
end

-- ==== ApplyRecoil - 开火时计算并施加后坐力：热度累积、首发倍率、偏移与镜头效果 ====
function SWEP:ApplyRecoil()
	if not self.Recoil_Enabled then return end

	local mod = self:GetRecoilModifier()
	local seed = "zs_" .. self:EntIndex() .. (self.ShotCount or 0)

	-- 1. 热度累积 (非线性曲线: 前几发稳定, 后段加速上升)
	self.RecoilAmount = self.RecoilAmount or 0
	self.RecoilAmount = math.min(self.RecoilAmount + (self.RecoilPerShot or 1), self.RecoilMax or 6)

	local heatRatio = self.RecoilAmount / math.max(self.RecoilMax or 6, 1)
	local buildupMult = 1 + ((self.RecoilModifierCap or 1.2) - 1) * (heatRatio * heatRatio)

	local finalMod = mod * buildupMult

	-- 2. 首发倍率 (COD特色: 第一发跳动通常更大)
	if self.ShotCount == 1 then
		finalMod = finalMod * (self.RecoilFirstShotMult or 1.0)
	end

	-- 3. 垂直后坐力
	local raw_up = (self.RecoilUp + util.SharedRandom(seed, 0, self.RecoilRandomUp)) * finalMod

	-- 4. 水平后坐力 (带偏向 + 热度增长)
	local bias = self.RecoilSideBias or 0
	local sideDir = util.SharedRandom(seed .. "dir", -1, 1)
	if math.abs(bias) > 0.01 then
		local biasRoll = util.SharedRandom(seed .. "bias", 0, 1)
		if biasRoll < (0.5 + math.abs(bias) * 0.4) then
			sideDir = bias > 0 and 1 or -1
		end
	end
	local sideMag = (self.RecoilSide + util.SharedRandom(seed .. "s", 0, self.RecoilRandomSide)) * finalMod
	local side = sideDir * sideMag * (1 + heatRatio * 0.5)

	-- 5. 客户端处理
	if CLIENT or game.SinglePlayer() then
		self.Recoil_Pending = self.Recoil_Pending or Angle(0, 0, 0)
		self.Recoil_RecoverPool = self.Recoil_RecoverPool or Angle(0, 0, 0)

		local max_up = self.RecoilMaxTotalUp or 45
		local current_total = (self.Recoil_RecoverPool.p or 0) + (self.Recoil_Pending.p or 0)
		if (current_total - raw_up) < -max_up then
			raw_up = math.max(0, current_total - (-max_up))
		end

		self.Recoil_Pending.p = self.Recoil_Pending.p - raw_up
		self.Recoil_Pending.y = self.Recoil_Pending.y + side

		if IsFirstTimePredicted() then
			-- 6. FOV冲击 (COD风格: 轻微的FOV缩放感)
			local fovPunch = self.CamRecoilFOV or 1.2
			if fovPunch > 0 then
				self.CamFOV_Vel = (self.CamFOV_Vel or 0) - math.abs(raw_up) * fovPunch * 8
			end

			-- 7. 镜头角度弹跳 (Camera Kick)
			local camUp = self.CamRecoilUp or 0
			local camSide = self.CamRecoilSide or 0
			local camRoll = self.CamRecoilRoll or 0

			self.CamRecoilTarget = self.CamRecoilTarget or Angle(0, 0, 0)
			self.CamRecoilCurrent = self.CamRecoilCurrent or Angle(0, 0, 0)

			if camUp > 0 or camSide > 0 then
				self.CamRecoilTarget.p = self.CamRecoilTarget.p - (camUp * finalMod * 40)
				self.CamRecoilTarget.y = self.CamRecoilTarget.y + util.SharedRandom(seed .. "cam_y", -1, 1) * camSide * finalMod * 40
			end

			if camRoll > 0 then
				self.CamRecoilRollVal = (self.CamRecoilRollVal or 0) + util.SharedRandom(seed .. "roll", -1, 1) * camRoll * finalMod * 30
			end

			-- 8. 枪模视觉物理 (Visual Recoil Physics)
			if self.UseVisualRecoil then
				self.VisRecoilAngVel = self.VisRecoilAngVel or Angle(0, 0, 0)
				self.VisRecoilVel = self.VisRecoilVel or Vector(0, 0, 0)

				local v_up = (self.VisualRecoilUp or -1.8) * finalMod
				local v_punch = (self.VisualRecoilPunch or 1.5) * finalMod
				local v_roll = (self.VisualRecoilRoll or 2.5) * finalMod

				self.VisRecoilAngVel.p = self.VisRecoilAngVel.p + (v_up * 10)
				self.VisRecoilAngVel.y = self.VisRecoilAngVel.y + (util.SharedRandom(seed .. "vr_y", -0.6, 0.6) * 5 * finalMod)
				self.VisRecoilAngVel.r = self.VisRecoilAngVel.r + (v_roll * util.SharedRandom(seed .. "vr_r", -1, 1) * 10)
				self.VisRecoilVel = self.VisRecoilVel + Vector(0, -v_punch * 15, math.abs(v_up) * 2.5)
			end
		end
	end

	self.last_shot_time = CurTime()
end
