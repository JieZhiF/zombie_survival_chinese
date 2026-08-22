-- ============================================================================
-- weapon_zs_base/sh_recoil.lua - 武器母本后坐力系统（共享）
-- 双轨分离（移植自 ARC9 原版机制）：
--   [实际轨] RecoilAccumUp/RecoilAccumSide 累积量 → cl_recoil_handler 在 CreateMove
--            中按时间步长渐进注入真实视角（平滑上抬、RecoilRise 回正、手动压枪抵扣）。
--            子弹自然跟随移动后的准星。停火指数衰减（见 sh_think ThinkRecoil）。
--   [视觉轨] CamRecoil 镜头弹跳 + VisRecoil 枪模 Verlet 弹簧 —— 纯表现层，
--            不写视角角度、不碰弹道。枪模水平抖动方向跟随实际轨走向。
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

-- ==== GetRecoilPatternDirection - 确定性连射方向图案 ====
-- 移植自 ARC9 RecoilPatternDirection：以武器类名派生种子，
-- 第 shot 发的方向 = 上一发方向 + 有界随机漂移；同一连射序号在
-- 服务端与客户端预测中得出完全一致的角度（弹道偏移双端一致的前提）。
function SWEP:GetRecoilPatternDirection(shot)
	self.RecoilPatternCache = self.RecoilPatternCache or {}

	local cached = self.RecoilPatternCache[shot]
	if cached then return cached end

	local prev = shot > 1 and (self.RecoilPatternCache[shot - 1] or 0) or 0

	-- 类名各字符字节值之和作为种子基数
	local numseed = 0
	for ch in string.gmatch(self:GetClass(), ".") do
		numseed = numseed + string.byte(ch)
	end

	math.randomseed((numseed % 16777216) + shot)
	local drift = self.RecoilPatternDrift or 0.35
	local dir = prev + math.Rand(-drift, drift)
	math.randomseed(math.Round(CurTime() * 1000) + self:EntIndex()) -- 归还全局随机熵（ARC9 同款技巧）

	self.RecoilPatternCache[shot] = dir
	return dir
end

-- ==== ApplyRecoil - 开火时累积实际弹道偏移并驱动视觉层 ====
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

	-- 2. 首发倍率（第一发跳动通常更大）
	if self.ShotCount == 1 then
		finalMod = finalMod * (self.RecoilFirstShotMult or 1.0)
	end

	-- 3. 确定性方向图案（ARC9式）：本发方位角由种子漂移决定
	local shot = math.max(self.ShotCount or 1, 1)
	local pat_dir = math.rad(self:GetRecoilPatternDirection(shot) - 90)

	-- 4. [实际轨] 后坐力累积 —— 共享域计算保证预测一致；
	--    RecoilAccumUp ≥ 0 表示向上爬升分量(度)，RecoilAccumSide 右偏为正。
	--    消费方：cl_recoil_handler 渐进注入视角（ARC9 原版路径）
	local scale = self.RecoilAccumScale or 1
	local up = (self.RecoilUp + util.SharedRandom(seed .. "bu", 0, self.RecoilRandomUp)) * finalMod * scale

	-- 水平走向：图案 cos 给出确定性左右漂移；RecoilSideBias 在图案相悖时按强度翻转
	local pat_side = math.cos(pat_dir)
	local bias = self.RecoilSideBias or 0
	if math.abs(bias) > 0.01 and pat_side * bias < 0 then
		if math.abs(math.sin(pat_dir)) < math.abs(bias) then
			pat_side = (bias > 0) and math.abs(pat_side) or -math.abs(pat_side)
		end
	end
	local side = pat_side * (self.RecoilSide + util.SharedRandom(seed .. "bs", 0, self.RecoilRandomSide)) * finalMod * scale

	self.RecoilAccumUp = self.RecoilAccumUp or 0
	self.RecoilAccumSide = self.RecoilAccumSide or 0

	-- 垂直爬升上限沿用 RecoilMaxTotalUp；水平对称限半
	local max_up = self.RecoilMaxTotalUp or 45
	self.RecoilAccumUp = math.Clamp(self.RecoilAccumUp + up, 0, max_up)
	self.RecoilAccumSide = math.Clamp(self.RecoilAccumSide + side, -max_up * 0.5, max_up * 0.5)

	local kick = up -- 视觉层的量纲回退基准（未显式配置 CamRecoil*/VisualRecoil* 时使用）

	-- 5. 视觉层 —— 仅表现，不触碰视角与弹道
	if CLIENT or game.SinglePlayer() then
		if IsFirstTimePredicted() then
			-- [镜头增强] 开镜进度按 CamRecoilADSMult 放大镜头层
			local ads = (CLIENT and self.GetIronsightDelta) and self:GetIronsightDelta() or 0
			local camBoost = 1 + ads * math.max((self.CamRecoilADSMult or 2) - 1, 0)

			-- 5.1 FOV 冲击（轻微的FOV收缩感）
			local fovPunch = self.CamRecoilFOV or 1.2
			if fovPunch > 0 then
				self.CamFOV_Vel = (self.CamFOV_Vel or 0) - math.abs(kick) * fovPunch * 8 * camBoost
			end

			-- 5.2 镜头角度弹跳 —— 单轴未显式配置时由弹道踢量自动演绎
			local camUp   = self.CamRecoilUp   or math.abs(kick) * (self.KickCameraGain or 1.2)
			local camSide = self.CamRecoilSide or math.abs(kick) * (self.KickCameraSideGain or 1.6)
			local camRoll = self.CamRecoilRoll or math.abs(kick) * (self.KickCameraRollGain or 1.5)

			self.CamRecoilTarget = self.CamRecoilTarget or Angle(0, 0, 0)
			self.CamRecoilCurrent = self.CamRecoilCurrent or Angle(0, 0, 0)

			self.CamRecoilTarget.p = self.CamRecoilTarget.p - (camUp * finalMod * 40 * camBoost)
			self.CamRecoilTarget.y = self.CamRecoilTarget.y + util.SharedRandom(seed .. "cam_y", -1, 1) * camSide * finalMod * 40 * camBoost

			self.CamRecoilRollVal = (self.CamRecoilRollVal or 0) + util.SharedRandom(seed .. "roll", -1, 1) * camRoll * finalMod * 30 * camBoost

			-- 5.3 枪模弹簧注入 —— ARC9 式双参数组：*（开镜组）与 *HipFire（腰射组）随开镜进度交叉渐变
			if self.UseVisualRecoil then
				self.VisRecoilAngVel = self.VisRecoilAngVel or Angle(0, 0, 0)
				self.VisRecoilVel = self.VisRecoilVel or Vector(0, 0, 0)

				local v_up = self.VisualRecoilUp or (-math.abs(kick) * (self.KickModelGain or 4.5))
				local v_punch = self.VisualRecoilPunch or (math.abs(kick) * (self.KickModelPunchGain or 3.75))
				local v_roll = self.VisualRecoilRoll or (math.abs(kick) * (self.KickModelRollGain or 6.25))

				local hip_up = self.VisualRecoilUpHipFire
				local hip_punch = self.VisualRecoilPunchHipFire
				local hip_roll = self.VisualRecoilRollHipFire
				if hip_up or hip_punch or hip_roll then
					v_up = Lerp(ads, hip_up or v_up, v_up)
					v_punch = Lerp(ads, hip_punch or v_punch, v_punch)
					v_roll = Lerp(ads, hip_roll or v_roll, v_roll)
				end

				self.VisRecoilAngVel.p = self.VisRecoilAngVel.p + (v_up * 10)
				-- 水平抖动方向跟随实际轨走向（ARC9：视觉 side 取自实际 RecoilSide 的符号）
				local side_sign = (self.RecoilAccumSide or 0) >= 0 and 1 or -1
				self.VisRecoilAngVel.y = self.VisRecoilAngVel.y + (side_sign * util.SharedRandom(seed .. "vr_y", 0.3, 0.6) * 5 * finalMod)
				self.VisRecoilAngVel.r = self.VisRecoilAngVel.r + (v_roll * util.SharedRandom(seed .. "vr_r", -1, 1) * 10)
				self.VisRecoilVel = self.VisRecoilVel + Vector(0, -v_punch * 15, math.abs(v_up) * 2.5)
			end
		end
	end

	self.last_shot_time = CurTime()
end
