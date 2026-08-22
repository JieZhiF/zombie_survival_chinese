-- ==========================================
-- 武器后坐力客户端处理系统（CreateMove 注入）
-- ARC9 原版渐进式视角上抬：
--   累积量(RecoilAccumUp/Side，见 sh_recoil.lua)按时间步长快照为注入速率，
--   逐帧平滑写入真实视角；RecoilRiseAngle 追踪总抬升，
--   玩家向下拉鼠标可抵扣(手动压枪)，停火后按 RecoilAutoControl 比例回正。
-- ==========================================

local function approxEqualsZero(a)
	return math.abs(a) < 0.005
end

-- ==== ARC9 原版渐进式视角上抬 ====
local function arc9_progressive(cmd, wep)
	local ft = FrameTime()
	if ft <= 0 then return end
	if ft > 0.1 then ft = 0.1 end

	-- 注入状态挂武器实例，切枪互不干扰
	wep.RecoilInjectUp = wep.RecoilInjectUp or 0
	wep.RecoilInjectSide = wep.RecoilInjectSide or 0
	wep.RecoilInjectNext = wep.RecoilInjectNext or 0
	wep.RecoilInjectProgress = wep.RecoilInjectProgress or 1
	wep.RecoilRiseAngle = wep.RecoilRiseAngle or Angle(0, 0, 0)
	if not wep.LastEyeAngles then wep.LastEyeAngles = cmd:GetViewAngles() end

	local ang = cmd:GetViewAngles()
	local timestep = wep.RecoilTimeStep or 0.06
	local risespeed = wep.RecoilRiseSpeed or 25

	-- [阶段1] 手动压枪检测：玩家主动拉动的视角增量从总抬升中扣除
	local diff = wep.LastEyeAngles - ang
	diff.p = math.NormalizeAngle(diff.p)
	diff.y = math.NormalizeAngle(diff.y)

	if not wep.RecoilAutoControl_DontTryToReturnBack then
		local rise = wep.RecoilRiseAngle
		if not approxEqualsZero(rise.p) then
			rise.p = math.Clamp(rise.p - diff.p, math.min(rise.p, 0), math.max(rise.p, 0))
		end
		if not approxEqualsZero(rise.y) then
			rise.y = math.Clamp(rise.y - diff.y, math.min(rise.y, 0), math.max(rise.y, 0))
		end
	end

	-- [阶段2] 时间步进采样：每步长重新快照累积量作为本步注入速率（ARC9 catchup 补帧）
	local catchup = 0
	if wep.RecoilInjectNext < CurTime() then
		wep.RecoilInjectUp = (wep.RecoilAccumUp or 0) * timestep
		wep.RecoilInjectSide = (wep.RecoilAccumSide or 0) * timestep
		wep.RecoilInjectNext = CurTime() + timestep
		if wep.RecoilInjectProgress < 1 then
			catchup = timestep * (1 - wep.RecoilInjectProgress)
		end
		wep.RecoilInjectProgress = 0
	end

	local cft = math.min(ft, timestep)
	local progress = cft / timestep
	if progress > 1 - wep.RecoilInjectProgress then
		cft = (1 - wep.RecoilInjectProgress) * timestep
		progress = 1 - wep.RecoilInjectProgress
	end
	cft = cft + catchup
	wep.RecoilInjectProgress = wep.RecoilInjectProgress + progress

	-- [阶段3] 渐进注入：累积量为正=向上爬升（Source俯仰正=朝下故取负）；水平右偏为正
	local step_p = -(wep.RecoilInjectUp) * risespeed * cft / timestep
	local step_y = (wep.RecoilInjectSide) * risespeed * cft / timestep

	if math.abs(step_p) > 1e-5 then ang.p = ang.p + step_p end
	if math.abs(step_y) > 1e-5 then ang.y = ang.y + step_y end

	wep.RecoilRiseAngle.p = wep.RecoilRiseAngle.p + step_p
	wep.RecoilRiseAngle.y = wep.RecoilRiseAngle.y + step_y

	-- [阶段4] 自动回正：恢复速度与剩余总抬升成正比（ARC9: Rise × AutoControl × cft × 2）
	if not wep.RecoilAutoControl_DontTryToReturnBack then
		local rec_p = wep.RecoilRiseAngle.p * (wep.RecoilAutoControl or 1) * cft * 2
		local rec_y = wep.RecoilRiseAngle.y * (wep.RecoilAutoControl or 1) * cft * 2

		if math.abs(rec_p) > 1e-5 then ang.p = ang.p - rec_p end
		if math.abs(rec_y) > 1e-5 then ang.y = ang.y - rec_y end

		wep.RecoilRiseAngle.p = wep.RecoilRiseAngle.p - rec_p
		wep.RecoilRiseAngle.y = wep.RecoilRiseAngle.y - rec_y
	end

	wep.RecoilRiseAngle:Normalize()

	cmd:SetViewAngles(ang)
	wep.LastEyeAngles = ang
end

hook.Add("CreateMove", "ZS_RecoilHandler", function(cmd)
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) or not wep.Recoil_Enabled then return end
	if not (CLIENT or game.SinglePlayer()) then return end

	arc9_progressive(cmd, wep)
end)
