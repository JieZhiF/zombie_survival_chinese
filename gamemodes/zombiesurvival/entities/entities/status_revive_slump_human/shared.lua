-- ============================================================================
-- status_revive_slump_human/shared.lua - 人类复活瘫倒状态（共享）
-- 负责：基于 status_revive_slump 的人类专属变体，额外记录人类变僵尸的初始化时间，
--       并通过 DT 数据同步到客户端（用于倒计时显示）
-- ============================================================================
ENT.Type = "anim"
ENT.Base = "status_revive_slump"

-- ==== SetZombieInitializeTime - 记录僵尸初始化时间戳到 DT 槽位 ====
function ENT:SetZombieInitializeTime(time)
	self:SetDTFloat(1, time)
end

-- ==== GetZombieInitializeTime - 读取僵尸初始化时间戳 ====
function ENT:GetZombieInitializeTime()
	return self:GetDTFloat(1)
end
