-- ============================================================================
-- point_zombiespawngroup.lua - 僵尸出生组点实体
-- 负责：地图中用于划分僵尸出生点组的标记点实体；
--       按 PVS 向客户端传输，供编辑工具/客户端逻辑读取
-- ============================================================================
AddCSLuaFile()

ENT.Type = "point"

-- ==== UpdateTransmitState - 传输策略：跟随 PVS 区域传输到客户端 ====
function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end