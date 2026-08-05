-- ============================================================================
-- status_spawnslow/init.lua - 出生减速状态实体（服务器端）
-- 负责：设置状态的持续到期时间（支持无限时长与立即失效）
-- ============================================================================

INC_SERVER()

-- ==== SetDie - 设置到期时间 ====
-- 0 表示立即结束；-1 表示无限持续；正数表示从现在起 fTime 秒后结束
function ENT:SetDie(fTime)
	if fTime == 0 or not fTime then
		-- 立即结束
		self.DieTime = 0
	elseif fTime == -1 then
		-- 无限持续（近乎永远）
		self.DieTime = 999999999
	else
		-- 正常定时到期，并同步持续时间到网络变量（供客户端计算剩余强度）
		self.DieTime = CurTime() + fTime
		self:SetDuration(fTime)
	end
end
