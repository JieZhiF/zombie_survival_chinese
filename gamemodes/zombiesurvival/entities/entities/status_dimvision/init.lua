-- ============================================================================
-- status_dimvision/init.lua - 暗视状态（服务器）
-- 负责：管理状态死亡时间（0/空=立即结束，-1=无限期，其余=定时结束）
-- ============================================================================
INC_SERVER()

-- ==== SetDie - 设置状态死亡时间 ====
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
