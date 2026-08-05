-- ============================================================================
-- init.lua - 冻结状态（服务端）：自定义死亡计时
-- 负责：按参数区分立即解除/永久冻结/定时冻结三种模式并同步时长
-- ============================================================================
INC_SERVER()

-- ==== SetDie - 设置状态结束时间：覆盖基类以支持特殊时长值 ====
function ENT:SetDie(fTime)
	if fTime == 0 or not fTime then
		-- 0 或空值：立即解除冻结
		self.DieTime = 0
	elseif fTime == -1 then
		-- -1：永久冻结（近似无限时长）
		self.DieTime = 999999999
	else
		-- 普通数值：按当前时间加上给定秒数，并同步客户端总时长
		self.DieTime = CurTime() + fTime
		self:SetDuration(fTime)
	end
end
