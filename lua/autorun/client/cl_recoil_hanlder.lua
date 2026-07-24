-- ==========================================
-- COD/Delta Force 风格后坐力客户端处理系统
-- ==========================================

local function approxEqualsZero(a)
	return math.abs(a) < 0.001
end

-- 手动压枪检测 (玩家向下拉鼠标时, 抑制自动回正)
hook.Add("CreateMove", "ZS_COD_RecoilApply", function(cmd)
	local ply = LocalPlayer()
	local wep = ply:GetActiveWeapon()
	if not IsValid(wep) or not wep.Recoil_Enabled then return end
	if not (CLIENT or game.SinglePlayer()) then return end

	local ft = FrameTime()
	if ft == 0 then return end
	if ft > 0.1 then ft = 0.1 end

	wep.Recoil_RecoverPool = wep.Recoil_RecoverPool or Angle(0, 0, 0)
	wep.Recoil_Pending = wep.Recoil_Pending or Angle(0, 0, 0)
	if not wep.LastEyeAngles then wep.LastEyeAngles = cmd:GetViewAngles() end

	local ang = cmd:GetViewAngles()

	-- [阶段1] 鼠标输入检测
	-- 计算玩家手动移动了多少视角
	local diff = wep.LastEyeAngles - ang
	diff.p = math.NormalizeAngle(diff.p)
	diff.y = math.NormalizeAngle(diff.y)

	-- 玩家向下拉鼠标时, 将其从恢复池中扣除 (支持主动压枪)
	if not wep.RecoilAutoControl_DontTryToReturnBack then
		-- Pitch: 枪口上扬是负Pitch, 玩家向下拉鼠标是 diff.p < 0
		if not approxEqualsZero(wep.Recoil_RecoverPool.p) then
			if wep.Recoil_RecoverPool.p < 0 then
				wep.Recoil_RecoverPool.p = math.Clamp(wep.Recoil_RecoverPool.p - diff.p, wep.Recoil_RecoverPool.p, 0)
			elseif wep.Recoil_RecoverPool.p > 0 then
				wep.Recoil_RecoverPool.p = math.Clamp(wep.Recoil_RecoverPool.p - diff.p, 0, wep.Recoil_RecoverPool.p)
			end
		end
		if not approxEqualsZero(wep.Recoil_RecoverPool.y) then
			if wep.Recoil_RecoverPool.y > 0 then
				wep.Recoil_RecoverPool.y = math.Clamp(wep.Recoil_RecoverPool.y, 0, wep.Recoil_RecoverPool.y - diff.y)
			elseif wep.Recoil_RecoverPool.y < 0 then
				wep.Recoil_RecoverPool.y = math.Clamp(wep.Recoil_RecoverPool.y, wep.Recoil_RecoverPool.y - diff.y, 0)
			end
		end
	end

	-- [阶段2] 将 Pending 池的后坐力注入视角 (COD风格: 快速注入, 不拖沓)
	local kickSpeed = ft * 80
	local progress = math.min(1, kickSpeed)

	local apply_p = wep.Recoil_Pending.p * progress
	local apply_y = wep.Recoil_Pending.y * progress

	wep.Recoil_Pending.p = wep.Recoil_Pending.p - apply_p
	wep.Recoil_Pending.y = wep.Recoil_Pending.y - apply_y

	ang.p = ang.p + apply_p
	ang.y = ang.y + apply_y

	wep.Recoil_RecoverPool.p = wep.Recoil_RecoverPool.p + apply_p
	wep.Recoil_RecoverPool.y = wep.Recoil_RecoverPool.y + apply_y

	-- [阶段3] 自动回正 (COD风格: 轻度回正, 玩家需要主动拉枪)
	local timeSinceShot = CurTime() - (wep.last_shot_time or 0)
	local isReloading = wep.IsReloadingRecoil or (wep.GetReloading and wep:GetReloading())

	if not wep.RecoilAutoControl_DontTryToReturnBack and (isReloading or timeSinceShot > (wep.RecoilAutoControlTime or 0.08)) then
		local shotBoost = (wep.ShotCount or 0) * (wep.RecoilAutoControl_PerShot or 0.15)
		local autoRate = (wep.RecoilAutoControl or 1) + shotBoost

		-- 恢复速度按帧率无关方式计算
		local recoverySpeed = autoRate * 0.8 * ft
		local rec = wep.Recoil_RecoverPool * recoverySpeed

		if math.abs(wep.Recoil_RecoverPool.p) > 0.001 or math.abs(wep.Recoil_RecoverPool.y) > 0.001 then
			ang.p = ang.p - rec.p
			ang.y = ang.y - rec.y

			wep.Recoil_RecoverPool.p = wep.Recoil_RecoverPool.p - rec.p
			wep.Recoil_RecoverPool.y = wep.Recoil_RecoverPool.y - rec.y
		else
			wep.Recoil_RecoverPool = Angle(0, 0, 0)
			wep.IsReloadingRecoil = false
		end
	end

	wep.Recoil_RecoverPool:Normalize()

	-- 清理微小的 Pending 残留
	if math.abs(wep.Recoil_Pending.p) < 0.001 and math.abs(wep.Recoil_Pending.y) < 0.001 then
		wep.Recoil_Pending = Angle(0, 0, 0)
	end

	cmd:SetViewAngles(ang)
	wep.LastEyeAngles = ang
end)

