-- ============================================================================
-- status_knockdown/shared.lua - 击倒状态（共享）
-- 负责：声明击倒持续时间与起始时间的 DT 访问器，供客户端倒下的物理模拟使用
-- ============================================================================
ENT.Type = "anim"
ENT.Base = "status__base"

-- 短暂状态：到期后自动移除（由基类处理）
ENT.Ephemeral = true

-- 击倒持续时间（秒）的 DT 访问器（Get/SetDuration）
AccessorFuncDT(ENT, "Duration", "Float", 0)
-- 击倒起始时间点的 DT 访问器（Get/SetStartTime）
AccessorFuncDT(ENT, "StartTime", "Float", 4)
