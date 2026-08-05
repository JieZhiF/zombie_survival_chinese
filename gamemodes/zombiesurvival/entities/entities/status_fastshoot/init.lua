-- ============================================================================
-- status_fastshoot/init.lua - 急速射击状态（服务器）
-- 负责：覆写状态时长设置，将剩余时长同步为 DT 供客户端显示
-- ============================================================================
INC_SERVER()

-- ==== SetDie - 覆写到期设置：记录绝对到期时间并同步持续时间字段 ====
function ENT:SetDie(fTime)
	if fTime == 0 or not fTime then
		self.DieTime = 0
	elseif fTime == -1 then
		-- 永久状态
		self.DieTime = 999999999
	else
		self.DieTime = CurTime() + fTime
		-- 同步持续时间到 DT，供客户端 HUD 读取
		self:SetDuration(fTime)
	end
end
