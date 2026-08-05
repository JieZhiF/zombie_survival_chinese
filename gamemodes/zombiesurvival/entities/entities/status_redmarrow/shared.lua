-- ============================================================================
-- status_redmarrow/shared.lua - 红骨髓状态（共享）
-- 负责：红骨髓僵尸职业（Red Marrow）的特殊状态实体；提供持续时间与
--       起始时间的数据表同步存取，以及"只延长不缩短"的到期时间设置
-- ============================================================================

-- 动画实体类型（可附着在拥有者身上跟随移动）
ENT.Type = "anim"
-- 继承通用状态实体基类，复用生命周期管理
ENT.Base = "status__base"

-- 数据表同步：持续时间（DT Float 槽 0）与起始时间（DT Float 槽 4）
AccessorFuncDT(ENT, "Duration", "Float", 0)
AccessorFuncDT(ENT, "StartTime", "Float", 4)

-- ==== PlayerSet - 状态附加到玩家身上时记录起始时间 ====
function ENT:PlayerSet(pl)
	self:SetStartTime(CurTime())
end

-- ==== SetDie - 设置到期时间：支持立即结束/永久持续/只延长三种语义 ====
function ENT:SetDie(fTime)
	-- 0 或空值：立即到期
	if fTime == 0 or not fTime then
		self.DieTime = 0
	-- -1：永久持续（用极大值近似无限时间）
	elseif fTime == -1 then
		self.DieTime = 999999999
	-- 正常时长：仅当新到期时间更晚时才延长，重复施放不会缩短剩余时间
	elseif self.DieTime < CurTime() + fTime then
		self.DieTime = CurTime() + fTime
		self:SetDuration(fTime)
	end
end