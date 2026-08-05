-- ============================================================================
-- status_sickness/shared.lua - 疾病状态（共享）
-- 负责：提供状态时长/开始时间的网络同步字段，附加到玩家时记录开始时间
-- ============================================================================
AddCSLuaFile()

-- 实体类型为动画实体，继承 status__base 状态基类
ENT.Type = "anim"
ENT.Base = "status__base"

-- 状态持续时间（秒）
AccessorFuncDT(ENT, "Duration", "Float", 0)
-- 状态开始时间（CurTime 时间戳）
AccessorFuncDT(ENT, "StartTime", "Float", 4)

-- ==== PlayerSet - 附加到玩家：记录状态开始时间 ====
function ENT:PlayerSet()
	self:SetStartTime(CurTime())
end
