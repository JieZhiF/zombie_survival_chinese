-- ============================================================================
-- status_frightened/init.lua - 恐惧状态（服务器）
-- 负责：实现自定义死亡时间语义：0 立即结束、-1 无限持续、
--       正数则从现在起再持续指定秒数
-- ============================================================================
INC_SERVER()

-- ==== SetDie - 自定义状态死亡时间：0 立即结束 / -1 无限 / 正数顺延 ====
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
