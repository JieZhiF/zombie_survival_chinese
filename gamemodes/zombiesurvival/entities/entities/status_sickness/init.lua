-- ============================================================================
-- status_sickness/init.lua - 疾病状态（服务器）
-- 负责：设定状态结束时间：0 立即结束，-1 永续，正数设定剩余时长
-- ============================================================================
INC_SERVER()

-- ==== SetDie - 设置结束时间：0 立即结束，-1 永续，正数设定剩余时长 ====
function ENT:SetDie(fTime)
	if fTime == 0 or not fTime then
		self.DieTime = 0
	elseif fTime == -1 then
		self.DieTime = 999999999
	else
		self.DieTime = CurTime() + fTime
		self:SetDuration(fTime)
	end
end
