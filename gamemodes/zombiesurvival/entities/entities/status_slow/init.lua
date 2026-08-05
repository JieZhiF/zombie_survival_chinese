-- ============================================================================
-- status_slow/init.lua - 减速状态（服务器）
-- 负责：到期时间（DieTime）的设置逻辑——支持立即结束/永久持续/常规
--       定时三种语义，常规时长直接覆盖旧的到期时间
-- ============================================================================
INC_SERVER()

-- ==== SetDie - 设置到期时间：立即结束/永久持续/常规定时 ====
function ENT:SetDie(fTime)
	-- 0 或空值：立即到期
	if fTime == 0 or not fTime then
		self.DieTime = 0
	-- -1：永久持续（用极大值近似无限时间）
	elseif fTime == -1 then
		self.DieTime = 999999999
	-- 常规时长：直接覆盖旧的到期时间并记录持续时间
	else
		self.DieTime = CurTime() + fTime
		self:SetDuration(fTime)
	end
end
